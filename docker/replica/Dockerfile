FROM mongo:6

COPY replica/script.js ./

COPY bin/wait /wait
RUN chmod +x /wait

CMD /wait && mongosh admin --host ev_mongo -u evse-admin -p evse-admin-pwd --file script.js

