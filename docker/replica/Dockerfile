FROM mongo:4.2

COPY script.js ./

COPY docker/bin/wait /wait
RUN chmod +x /wait

CMD /wait && mongo admin --host ev_mongo -u evse-admin -p evse-admin-pwd script.js



