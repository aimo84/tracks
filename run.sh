# candidate array to change
buffer_pool_size_arr=('128M' '256M' '512M' '1G')
buffer_instance_arr=(8 16 32 64)
old_blocks_pct_arr=(5 50 500)
random_read_ahead_arr=(0 1)
read_ahead_threshold_arr=(64)

#buffer_pool_size_arr=('1G')
#buffer_instance_arr=(64)
#old_blocks_pct_arr=(5 50 500)
#random_read_ahead_arr=(0 1)
#read_ahead_threshold_arr=(0 32 64)

# properties
#buffer_pool_size='512M'
#buffer_instance=8
#old_blocks_pct=5
#random_read_ahead=0
#read_ahead_threshold=0
for (( buffer_pool_size_index=0; buffer_pool_size_index<${#buffer_pool_size_arr[@]}; buffer_pool_size_index++ ));
do
    buffer_pool_size=${buffer_pool_size_arr[buffer_pool_size_index]}
    for (( buffer_instance_index=0; buffer_instance_index<${#buffer_instance_arr[@]}; buffer_instance_index++ ));
    do
        buffer_instance=${buffer_instance_arr[buffer_instance_index]}
        for (( old_blocks_pct_index=0; old_blocks_pct_index<${#old_blocks_pct_arr[@]}; old_blocks_pct_index++ ));
        do
            old_blocks_pct=${old_blocks_pct_arr[old_blocks_pct_index]}
            for (( random_read_ahead_index=0; random_read_ahead_index<${#random_read_ahead_arr[@]}; random_read_ahead_index++ ));
            do
                random_read_ahead=${random_read_ahead_arr[random_read_ahead_index]}
                for (( read_ahead_threshold_index=0; read_ahead_threshold_index<${#read_ahead_threshold_arr[@]}; read_ahead_threshold_index++ ));
                do
                    read_ahead_threshold=${read_ahead_threshold_arr[read_ahead_threshold_index]}
                    echo '[mysqld]' > config.cnf
                    echo 'innodb_buffer_pool_size=' $buffer_pool_size >> config.cnf
                    echo 'innodb_buffer_pool_instances=' $buffer_instance >> config.cnf
                    echo 'innodb_old_blocks_pct=' $old_blocks_pct >> config.cnf
                    echo 'innodb_random_read_ahead=' $random_read_ahead >> config.cnf   
                    echo 'innodb_read_ahead_threshold=' $read_ahead_threshold >> config.cnf
                    logfile="config_log/#$buffer_pool_size#$buffer_instance#$old_blocks_pct#$random_read_ahead#$read_ahead_threshold.log"
                    if [ -f "$logfile" ] ; then
                        break
                    fi
                    sudo cp config.cnf /etc/mysql/conf.d
                    mysql-ctl restart
                    echo $logfile
                    sleep 10
                    rails s -b 0.0.0.0 -p 8080 -e production >> $logfile &
                    echo "PROCESS $! START TO RUN"
                    sleep 15
                    echo "RUN SPIDER"
                    ./spider.sh
                    echo "KILL PROCESS $!"
                    kill -9 $!
                done    
            done
        done
    done
done
#railss-b0.0.0.0-p8080-eproduction>>test.log&
#echo'finish'
