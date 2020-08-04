#!/bin/sh
#S3DIR=s3://client-center-deployment-packages
USAGE="Usage: $0 [-e env_name] [-v version] [-x]"
START_TIME=$(date +%s)
ACTUAL_USER=`logname`
alpha_ec2="alpha-webql.ql2.com"
nutmeg_ec2=""
prod_ec2=""

. ~/.bash_profile

# Check for at least one param otherwise bomb out.
if [ $# -eq 0 ]; then
   echo $USAGE
   exit 1
fi

# Check that "-e" parameter exists.  The case statement below will check validity of parameter value.
SAW_ENV=no
for i in "$@"; do
   if [ $i = "-e" ]; then
      SAW_ENV=yes
   fi
done
if [ $SAW_ENV = "no" ]; then
   echo $USAGE
   exit 1
fi

while getopts ":e:xr:v:" OPT; do
    case $OPT in
        e)
            if [ "$OPTARG" = "alpha" ] ||  [ "$OPTARG" = "prod" ] || [ "$OPTARG" = "nutmeg" ]
            then
                DEPLOY_ENV=$OPTARG
            else
                echo $OPTARG
                echo Enter the name of a deployment environment: "[alpha|prod|nutmeg]"
                exit 1
            fi
        ;;
        x) RESTART_REMOTE="yes";;
        v) VERSION=$OPTARG;;
        \?) echo "    unknown flag: $OPTARG"
            echo "    $USAGE"
            exit 1
    esac
done

shift $(($OPTIND - 1))

# Disallow restart for production builds
## Copy build package from ftp1

cd /var/lib/jenkins/webql_build/${DEPLOY_ENV}
echo "Working directory is `pwd`"
echo "copy from ftp file ${S3DIR}/${DEPLOY_ENV}/jboss-deploy-${VERSION}.tar.gz"
/usr/bin/scp root@ftp1.ql2.com:/home/ftp/webql_builds/${VERSION}/CentOS6.7/*.tgz /var/lib/jenkins/webql_build/${DEPLOY_ENV}/

