#!/bin/bash

# ==========================================
# Usage:
# ./triage.sh startup-tenant-alpha
# ==========================================

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "Usage: ./triage.sh <namespace>"
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

OUTPUT_FILE="triage-${NAMESPACE}-${TIMESTAMP}.txt"

echo "Namespace: $NAMESPACE" > $OUTPUT_FILE
echo "Triage Time: $(date)" >> $OUTPUT_FILE
echo "===================================" >> $OUTPUT_FILE

# Find CrashLoopBackOff Pods
PODS=$(kubectl get pods -n $NAMESPACE --no-headers | \
grep CrashLoopBackOff | awk '{print $1}')

if [ -z "$PODS" ]; then
  echo "No CrashLoopBackOff pods found."
  exit 0
fi

for POD in $PODS
do
  echo "" >> $OUTPUT_FILE
  echo "===================================" >> $OUTPUT_FILE
  echo "Pod: $POD" >> $OUTPUT_FILE
  echo "===================================" >> $OUTPUT_FILE

  echo "" >> $OUTPUT_FILE
  echo "----- kubectl describe pod -----" >> $OUTPUT_FILE

  kubectl describe pod $POD -n $NAMESPACE >> $OUTPUT_FILE

  echo "" >> $OUTPUT_FILE
  echo "----- Last 50 Log Lines -----" >> $OUTPUT_FILE

  kubectl logs $POD \
    -n $NAMESPACE \
    --tail=50 >> $OUTPUT_FILE

done

echo "Triage completed."
echo "Logs written to: $OUTPUT_FILE"
