if [ -z "$1" ]
then
    echo "sh build.sh [project]"
    exit;
fi

sed -i '' -e 's/PROJECT_NAME/$1/g' vars.tf
