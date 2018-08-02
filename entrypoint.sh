#!/bin/bash

function php_generator {
    if [ ! -d phpout ]; then
        mkdir phpout
    fi

    protoc-gen-php \
        -i ./ \
        -i /usr/local/include \
        -i $GOPATH/src \
        -i $GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        -o ./phpout \
        *.proto
}

function go_generator {
    if [ ! -d goout ]; then
        mkdir goout
    fi

    protoc -I/usr/local/include -I. \
        -I$GOPATH/src \
        -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        --go_out=plugins=grpc:goout \
        *.proto

    protoc -I/usr/local/include -I. \
        -I$GOPATH/src \
        -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        --gogo_out=Mgoogle/api/annotations.proto=github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis/google/api,plugins=grpc:. \
        *.proto

    protoc -I/usr/local/include -I. \
        -I$GOPATH/src \
        -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        --grpc-gateway_out=logtostderr=true:. \
        *.proto

    protoc -I/usr/local/include -I. \
        -I$GOPATH/src \
        -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        --swagger_out=logtostderr=true:. \
        *.proto
}

function js_generator {
    if [ ! -d jsout ]; then
        mkdir jsout
    fi


    # Path to this plugin
    PROTOC_GEN_TS_PATH="/usr/local/src/ts-protoc-gen/node_modules/.bin/protoc-gen-ts"

    # Directory to write generated code to (.js and .d.ts files)
    OUT_DIR="./jsout"

    protoc -I/usr/local/include -I. \
        -I$GOPATH/src \
        -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
        --plugin="protoc-gen-ts=${PROTOC_GEN_TS_PATH}" \
        --js_out="import_style=commonjs,binary:${OUT_DIR}" \
        --ts_out="service=true:${OUT_DIR}" \
        *.proto
}

case $1 in
    php)
    echo "...run generator for php only..."
    php_generator
    ;;

    js)
    echo "...run generator for js only..."
    js_generator
    ;;

    go)
    echo "...run generator for go only..."
    go_generator
    ;;
    *)

    php_generator
    js_generator
    go_generator
    ;;
esac