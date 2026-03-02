#! /usr/bin/env bash

export AWS_PROFILE=${AWS_PROFILE:gaas-dev-mgmt-superuser}
export NL="|"



function run(){

  # =========================================
  # Imports =========================================
  mkdir -p ./out ./dist
  rm  ./out/*


  if [ -z "$AWS_PROFILE" ]; then
    ask-aws-profile
  fi


  . ./ec2.sh
  . ./ssm.sh
  . ./cw.sh

  # =========================================
  # generate xlsx =========================================
  find out/ -type f -empty -print -delete
  ssconvert \
    -T Gnumeric_Excel:xlsx2 \
    -M dist/$AWS_PROFILE.xlsx  \
    out/*
  rm -rf out

  # unoconv --format xls cw.metrics.csv cw.logs.csv cw.alarms.csv
  # ssconvert  --list-exporters

  # =========================================
  # cleanup =========================================

}





function aws-query() { echo "{ Results:$(echo $@ | tr '\n' ' '), NextToken:NextToken }";  }
# function aws_call() {
#   AWS_CMD="$(echo "$@ --output json" | sed "s/awsv-exec/aws-vault exec ${AWS_PROFILE:-default} -- aws/g")"
#   echo "$AWS_CMD"
# }
function aws-call() {
  set -e

  unset PREV_TOKEN NEXT_TOKEN;
  AWS_CMD="$(echo "$@ --output json" | sed "s/awsv-exec/aws-vault exec ${AWS_PROFILE:-default} -- aws/g")"
  OUT=$(eval $AWS_CMD)

  NEXT_TOKEN=$(echo "$OUT" | jq -r '.NextToken')
  RESULTS=$(echo "$OUT" | jq ".Results")
  LEN=$(echo "$OUT" | jq '.Results | length')
  
  #echo "$OUT";

  i=0;((T=i+LEN));
  while [ "$NEXT_TOKEN" != "null" ] && [ ! -z "$NEXT_TOKEN" ] && [ "$LEN" -gt 0 ]; do
    # echo -e "\nhas length ($T+$LEN) & token ($NEXT_TOKEN)"

    #   echo -e ":: \n:: ${LEN:-''}\n ${NEXT_TOKEN:-''}\n"
    AWS_NEXT_CMD="$AWS_CMD --starting-token $NEXT_TOKEN"
    unset NEXT_TOKEN OUT RESULTS2 LEN 
    #   echo "$AWS_NEXT_CMD"

    OUT=$(eval $AWS_NEXT_CMD)
    RESULTS2=$(echo "$OUT" | jq '.Results')
    LEN=$(echo "$RESULTS2" | jq '. | length')
    NEXT_TOKEN=$(echo "$OUT" | jq -r '.NextToken')

    if [ "$PREV_TOKEN" == "$NEXT_TOKEN" ]; then NEXT_TOKEN="null";
    else PREV_TOKEN="$NEXT_TOKEN"; fi

    RESULTS=$(echo -e "$(echo $RESULTS)\n$(echo $RESULTS2)" | jq -s 'flatten(1)')
    #   echo -e ":: \n:: ${LEN:-''}\n ${NEXT_TOKEN:-''}\n"

    if [ "$i" -gt 10 ]; then NEXT_TOKEN='null'; fi;
    ((i=i+1));((T=T+LEN));
  done

  echo "$RESULTS"
}
function ask-aws-profile(){
  while true; do
    read -p "What aws profile do you wish to use (or 'list' to see profiles) ? " profile
    if [ "$profile" == "list" ]; then
      aws-vault list
    elif [[ ! -z "$profile" ]]; then 
      echo "New AWS profile: $profile"
      export AWS_PROFILE="$profile";
      return;
    else
      return;
    fi
  done
}



run