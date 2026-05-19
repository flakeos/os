#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?APP_NAME required}"
shift

CG="/sys/fs/cgroup/${APP_NAME}"
mkdir -p "${CG}"

echo "+cpu +memory +io +pids +cpuset" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || true

while [ $# -ge 2 ]; do
  BEAN="$1"
  RES_CPU="$2"
  RES_MEM="$3"
  RES_MEM_MAX="$4"
  RES_PIDS="$5"
  RES_IO_RBPS="$6"
  RES_IO_WBPS="$7"
  RES_NUMA="$8"
  shift 8

  mkdir -p "${CG}/${BEAN}"
  [ "${RES_CPU}" != "0" ] && echo "${RES_CPU}" > "${CG}/${BEAN}/cpu.max" 2>/dev/null || true
  [ "${RES_MEM}" != "0" ] && echo "${RES_MEM}" > "${CG}/${BEAN}/memory.max" 2>/dev/null || true
  [ "${RES_MEM}" != "0" ] && echo "${RES_MEM}" > "${CG}/${BEAN}/memory.high" 2>/dev/null || true
  [ "${RES_MEM_MAX}" != "0" ] && echo "${RES_MEM_MAX}" > "${CG}/${BEAN}/memory.swap.max" 2>/dev/null || true
  [ "${RES_PIDS}" != "0" ] && echo "${RES_PIDS}" > "${CG}/${BEAN}/pids.max" 2>/dev/null || true
  [ "${RES_IO_RBPS}" != "0" ] && echo "${RES_IO_RBPS}" > "${CG}/${BEAN}/io.max" 2>/dev/null || true
  [ "${RES_NUMA}" != "" ] && echo "${RES_NUMA//,/ }" > "${CG}/${BEAN}/cpuset.cpus" 2>/dev/null || true
  [ "${RES_NUMA}" != "" ] && echo "${RES_NUMA//,/ }" > "${CG}/${BEAN}/cpuset.mems" 2>/dev/null || true
done
