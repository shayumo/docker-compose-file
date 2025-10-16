#!/bin/bash

# 多线程异步压力测试脚本 - 实现每秒指定请求数
# 使用方法: ./load_test.sh <目标URL> <测试持续时间(秒)> <并发数>

# 检查脚本是否有执行权限
if [ ! -x "$0" ]; then
  echo "错误: 脚本没有执行权限，请运行 chmod +x $0"
  exit 1
fi

# 默认参数
TARGET_URL="http://localhost:8000"
DURATION=60
REQUESTS_PER_SECOND=100  # 用户已修改为100
CONCURRENCY=10  # 默认并发数

# 解析命令行参数
if [ $# -gt 0 ]; then
  TARGET_URL=$1
fi

if [ $# -gt 1 ]; then
  DURATION=$2
fi

if [ $# -gt 2 ]; then
  CONCURRENCY=$3
fi

# 检查必要的命令是否安装
command -v curl >/dev/null 2>&1 || { echo "错误: 需要安装curl命令才能运行此脚本"; exit 1; }

# 创建结果目录 - 使用时间戳作为唯一标识
RESULTS_DIR="./load_test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"
RESULTS_FILE="$RESULTS_DIR/results.log"
SUMMARY_FILE="$RESULTS_DIR/summary.txt"

# 初始化结果文件
touch "$RESULTS_FILE"
touch "$SUMMARY_FILE"

# 记录请求和完整响应的函数
send_request() {
  # 功能: 发送HTTP请求并记录完整响应信息
  # 参数: request_id - 请求唯一标识符
  # 返回: 请求ID和响应码，格式为"request_id,response_code"
  
  local request_id=$1
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S.%N")
  local response_code
  local response_body
  local temp_file=$(mktemp)  # 创建临时文件存储响应
  
  # 发送请求，将响应体保存到临时文件，同时获取响应码
  # 使用更可靠的方式分离响应体和响应码
  response_code=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"email":"410291479"}' "$TARGET_URL" \
    -w "%{http_code}" -o "$temp_file" 2>/dev/null)
  
  # 从临时文件读取响应体
  response_body=$(cat "$temp_file")
  
  # 清理临时文件
  rm -f "$temp_file"
  
  # 将完整结果写入日志文件，使用明确的分隔符
  echo "=====REQUEST_START=====$request_id=====$timestamp=====$response_code=====" >> "$RESULTS_FILE"
  echo "$response_body" >> "$RESULTS_FILE"
  echo "=====REQUEST_END=====" >> "$RESULTS_FILE"
  
  # 返回响应码供进一步处理
  echo "$request_id,$response_code"
}

# 主测试函数
run_test() {
  # 功能: 执行多线程压力测试
  # 返回: 统计数据，格式为"总请求数,成功数,失败数"
  
  local start_time=$(date +%s)
  local total_requests=0
  local success_count=0
  local fail_count=0
  
  echo "开始多线程异步压力测试..." | tee "$SUMMARY_FILE"
  echo "目标URL: $TARGET_URL" | tee -a "$SUMMARY_FILE"
  echo "每秒请求数: $REQUESTS_PER_SECOND" | tee -a "$SUMMARY_FILE"
  echo "测试持续时间: $DURATION秒" | tee -a "$SUMMARY_FILE"
  echo "并发数: $CONCURRENCY" | tee -a "$SUMMARY_FILE"
  echo "结果文件: $RESULTS_FILE" | tee -a "$SUMMARY_FILE"
  echo "----------------------------------------" | tee -a "$SUMMARY_FILE"
  
  # 运行测试直到达到指定的持续时间
  while [ $(( $(date +%s) - start_time )) -lt $DURATION ]; do
    # 记录这一秒的开始时间
    local second_start=$(date +%s)
    local requests_this_second=0
    local thread_results=()
    
    # 计算每个并发进程需要处理的请求数
    local requests_per_thread=$((REQUESTS_PER_SECOND / CONCURRENCY))
    local remaining_requests=$((REQUESTS_PER_SECOND % CONCURRENCY))
    
    # 启动并发线程发送请求
    local thread_id=0
    while [ $thread_id -lt $CONCURRENCY ]; do
      # 确定此线程需要发送的请求数
      local thread_requests=$requests_per_thread
      if [ $thread_id -lt $remaining_requests ]; then
        thread_requests=$((thread_requests + 1))
      fi
      
      # 此线程的起始请求ID
      local start_id=$((total_requests + 1))
      local end_id=$((total_requests + thread_requests))
      
      # 在后台运行此线程，并将结果捕获到临时文件
      local thread_result_file="$RESULTS_DIR/thread_${thread_id}_result.txt"
      
      {
        for ((i=start_id; i<=end_id; i++)); do
          send_request "$i"
        done
      } > "$thread_result_file" &
      
      # 保存线程结果文件路径
      thread_results+="$thread_result_file"
      
      # 更新请求计数
      total_requests=$end_id
      requests_this_second=$((requests_this_second + thread_requests))
      thread_id=$((thread_id + 1))
    done
    
    # 等待所有后台任务完成
    wait
    
    # 处理所有线程的结果，统计成功和失败请求
    for thread_file in "${thread_results[@]}"; do
      while IFS=, read -r _ response_code; do
        if [[ $response_code == 2* || $response_code == 3* ]]; then
          success_count=$((success_count + 1))
        else
          fail_count=$((fail_count + 1))
        fi
      done < "$thread_file"
      
      # 清理线程临时文件
      rm -f "$thread_file"
    done
    
    # 计算这一轮循环花费的时间
    local second_elapsed=$(( $(date +%s) - second_start ))
    
    # 如果这一轮循环花费的时间小于1秒，则等待剩余时间以确保每秒只发送指定数量的请求
    if [ $second_elapsed -lt 1 ]; then
      local sleep_time=$((1 - second_elapsed))
      sleep $sleep_time
    fi
    
    # 实时显示进度
    local current_time=$(( $(date +%s) - start_time ))
    echo -e "进行中: ${current_time}秒 | 已发送请求: ${total_requests} | 成功: ${success_count} | 失败: ${fail_count}"
  done
  
  # 返回统计信息
  echo "$total_requests,$success_count,$fail_count"
}

# 分析结果的函数
analyze_results() {
  # 功能: 分析测试结果并生成报告
  # 参数: stats - 测试统计数据，格式为"总请求数,成功数,失败数"
  
  local stats=$1
  local total_requests=$(echo "$stats" | cut -d',' -f1)
  local success_count=$(echo "$stats" | cut -d',' -f2)
  local fail_count=$(echo "$stats" | cut -d',' -f3)
  
  # 计算统计信息
  local total_time=$DURATION
  local success_rate=0
  local avg_rps=0
  
  if [ $total_requests -gt 0 ]; then
    success_rate=$((success_count * 100 / total_requests))
  fi
  
  if [ $total_time -gt 0 ]; then
    avg_rps=$((total_requests / total_time))
  fi
  
  # 显示结果
  echo "----------------------------------------" | tee -a "$SUMMARY_FILE"
  echo "压力测试完成!" | tee -a "$SUMMARY_FILE"
  echo "测试总时间: ${total_time}秒" | tee -a "$SUMMARY_FILE"
  echo "总请求数: ${total_requests}" | tee -a "$SUMMARY_FILE"
  echo "成功请求: ${success_count}" | tee -a "$SUMMARY_FILE"
  echo "失败请求: ${fail_count}" | tee -a "$SUMMARY_FILE"
  echo "成功率: ${success_rate}%" | tee -a "$SUMMARY_FILE"
  echo "平均每秒请求数: ${avg_rps}" | tee -a "$SUMMARY_FILE"
  echo "完整结果保存在: $RESULTS_FILE" | tee -a "$SUMMARY_FILE"
  echo "测试摘要保存在: $SUMMARY_FILE" | tee -a "$SUMMARY_FILE"
}

# 执行测试
STATS=$(run_test)

# 分析结果
analyze_results "$STATS"

# 不再清理结果文件，而是保留供后续分析
echo "测试完成，所有结果文件已保留。"