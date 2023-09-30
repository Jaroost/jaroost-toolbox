FROM dpage/pgadmin4:latest

USER root
#to use envsbust
RUN apk add envsubst

USER pgadmin