#!/bin/bash
checkIPMITool() {
    echo "Checking if ipmitool is installed..."
    if ipmitool -V > /dev/null 2>&1; then
        echo "Checking if ipmitool is installed...passed"
        return 0
    else
        echo "ipmitool is not installed. Please install it and try again."
        exit 1
    fi
}

getInfo() {
    echo "Getting system information..."
    $ipmicmd sensor
}

getInletTemp() {
    echo "Getting board temperature..."
    
    inlet_temp=$($ipmicmd sdr type Temperature | grep -i "Inlet_Temp" | awk '{print $9}')
    if [ -n "$inlet_temp" ]; then
        echo "Board temperature: $inlet_temp"
    else
        echo "Could not retrieve inlet temperature."
    fi
}

setPwm() {
    pwm_value=$1
    echo "Setting fan PWM to $pwm_value%"
    $ipmicmd raw 0x0e 0x65 0 $pwm_value
    if [ $? -eq 0 ]; then
        echo "Fan PWM set to $pwm_value% successfully."
    else
        echo "Failed to set fan PWM."
    fi
}

fixSysFan() {
    echo "Setting fan control to automatic mode"
    $ipmicmd rraw 0x0e 0x65 1 0x64
    if [ $? -eq 0 ]; then
        echo "Fan control set to automatic mode successfully."
    else
        echo "Failed to set fan control to automatic mode."
    fi
}

setAuto() {
    echo "Fan control set to auto mode..."
    while true; do
        getInletTemp
        if [[ $inlet_temp -lt 35 ]]; then
            pwm_value=10
        elif [[ $inlet_temp -lt 40 ]]; then
            pwm_value=20
        elif [[ $inlet_temp -lt 45 ]]; then
            pwm_value=30
        elif [[ $inlet_temp -lt 50 ]]; then
            pwm_value=40
        elif [[ $inlet_temp -lt 60 ]]; then
            pwm_value=50
        else
            pwm_value=100
        fi
        
        if [[ $pwm_value -ne $current_pwm ]]; then
            setPwm $pwm_value
            current_pwm=$pwm_value
        else
            echo "PWM is already set to $current_pwm%, no change needed."
        fi
        sleep 30 
    done;

}


inlet_temp=0
current_pwm=0
host=192.168.100.8
user=admin
passwd=admin
# set default pwn
current_pwm=20

ipmicmd="ipmitool -I lanplus -H $host -U $user -P $passwd "
checkIPMITool
# getInletTemp
# echo $temp

mode=$1
case $mode in 
    info)
        getInfo
        ;;
    auto)
        setAuto
        ;;
    fixed)
        fixSysFan
        ;;
    *)
        echo "Usage: $0 {auto|fixed|info}"
        exit 1
        ;;
esac


