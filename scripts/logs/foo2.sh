sec_count() {
  LC=`wc -l $LOG | sed 's/\([0-9]*\).*/\1/'`
    while true
      do
        NC=`wc -l $LOG | sed 's/\([0-9]*\).*/\1/'`
        DIFF=$(( NC - LC ))
        RATE=$(echo "$DIFF / $FREQ" | bc -l)
        echo $RATE
        LC=$NC
        sleep 2
    done
}

