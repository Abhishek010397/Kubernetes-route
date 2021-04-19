#!/bin/bash 
#this script logs into argocd server and deploys to argocd 
#input -e environment 
#script expects ARGOCD_URl, ARGOCD_USERNAME, and ARGOCD_PASSWORD as environment variables 
#script optionally accepts DEV_API_SERVER_ENDPOINT, INT_API_SERVER_ENDPOINT, TEST_API_SERVER_ENDPOINT, and PROD_API_SERVER_ENDPOINT as environment variables 
#this script is intended to run in gitlab-ci 
wget --no-check certificate https://gitlab.global.com/it-repos/-automation/deployment/library.sh -O deployment-library.sh
chmod -R 755 deployment-library.sh 
source ./deploymentlibrary.sh 
#input error handling 1)error_type 2)arg (optional) 
usage() { 
    error_type=$1 
    arg=$2 
    case "${error_type} in 
       'missing param') 
            exit 1
            ;; 
       'invalid_param') 
            err "Invalid input: $arg" 
            err "Accepted input flags are -e"
            err "Please contact Platform Engineering." 
            exit 1 
            ;; 
        *) 
            err "Invalid usage call with arg: $arg" 
            err "Please contact Platform Engineering." 
            exit 1
    esac 
}
set_destination_server() {
    case "${environment}"  in 
        dev) 
            if [[ -n "$DEV API_SERVER_ENDPOINT" ]]; then 
                echo "$DEV_API_SERVER_ENDPOINT" 
            else 
                echo 'https://3242349475974750.gr7.us-west-2.eks.amazonaws.com' 
            fi 
            ;;
        int) 
            if [[ -n "$INT_API_SERVER_ENDPOINT" ]]; then 
                echo "$INT_API_SERVER_ENDPOINT" 
            else 
                echo 'https://662343405r438wqseyg7.skl.us-west-2.eks.amazonaws.com' 
            fi
            ;;
         test) 
            if [[ -n "$TEST_API_SERVER_ENDPOINT" ]]; then 
                echo "$TEST_API_SERVER_ENDPOINT" 
            else 
                echo 'https://709869970hkjh79810166AF8O.skl.us-west-2.eks.amazonaws.com' 
            fi
            ;;
         prod) 
            if [[ -n "$PROD_API_SERVER_ENDPOINT" ]]; then 
                echo "$PROD_API_SERVER_ENDPOINT" 
            else 
               echo 'https://52392B5CC77FFB7697091653.y14.us-west-2.eks.amazonaws.com' 
            fi
            ;;
        *)
            usage 'invalid_param' "$(OPTARG}"
            ;;
    esac
}
set_argocd_url() { 
    case "${environment}" in 
        *prod) 
            echo 'argocd.domain.io' 
            ;;
        *)
            echo 'argocd.domain.io'
            ;;
    esac
} 
set_values_file_name() { 
    case "${environment}" in 
        dev) 
            echo 'values-dev.yaml' 
            ;;
        int) 
            echo 'values-int.yaml' 
            ;;
        test) 
            echo 'values-test.yaml' 
            ;;
        prod) 
            echo "values-prod.yaml"  
            ;;
        *)
            usage 'invalid_param' "${OPTARG}"
            ;;
    esac
}

set_argo_user() {
     info "setting argo user" 
     case "${environment}" in 
        *prod) 
            ARGO_USER="$ARGOCD_USERNAME_PROD"
            ;; 
       *) 
            ARGO_USER="$ARGOCD_USERNAME" 
    esac
} 
set_argo_pass() { 
    info "setting argo pass" 
    case "${environment}" in 
       *prod) 
            ARGO_PASS="$ARGOCD_PASSWORD_PROD"
            ;;
        *) 
            ARGO_PASS="$ARGOCD_PASSWORD"
            ;; 
    esac
}

enforce_required_input() {
     if [[ -z "$environment" ]]; then 
        err "environment not populated. Please include -e arg. Please contact" 
        exit 1 
    fi
} 
while getopts ":e:" arg; do 
      case "$(arg)" in 
        e) 
           environment=${OPTARG}
           ;;
        *) 
           usage 'invalid_param' "$(OPTARG)" 
           ;;
    esac 
done 

enforce_required_input 
DESTINATION_SERVER=$(set_destination_server "$environment") 
ARGOCD_SERVER_URL=$(set_argocd_url) 
VALUES_FILE=$(set_values_file_name) 
set_argo_user 
set_argo_pass 

info "argocd login $ARGOCD_SERVER_URL --insecure --username $ARGOCD_USERNAME --password ****" 
argocd login $ARGOCD_SERVER_URL --insecure --username $ARGO_USER --password $ARGO_PASS 
REPO_URL="$CI_PROJECT_URL".git 

gitlab_subgroup=$(get_gitlab_subgroup "$CI_PROJECT_NAMESPACE") 

info "argocd app create --name $CI_PROJECT_NAME-${environment} --repo $REPO_URL --path helm --revision HEAD --dest-namespace $CI_PROJECT_NAME --project ${gitlab_subgroup} --dest-server $DESTINATION_SERVER --values $VALUES_FILE --values values-global.yaml --upsert" 
argocd app create --name "$CI_PROJECT_NAME-${environment} --repo "$REPO_URL --path helm --revision HEAD dest namespace digital-route --project "${gitlab_subgroup}"  --dest-server "$DESTINATION_SERVER"  --values  "$VALUES_FILE"  --values "values-global.yaml" --upsert
info "argocd app sync "${CI_PROJECT_NAME}-${environment}" --prune
argocd app sync "${CI_PROJECT_NAME}-${environment}" --prune 
info "argocd app wait "${CI_PROJECT_NAME}-${environment}" --health --sync --timeout 600" 
argocd app wait "${CI_PROJECT_NAME}-${environment}"  --health --sync --timeout 600 


 
