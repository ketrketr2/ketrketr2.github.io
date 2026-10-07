#!/bin/bash
cat > /tmp/p.mjs <<'JS'
import http from 'node:http'; import https from 'node:https';
const T='mac-mini.tailec77f5.ts.net', P=10000;
http.createServer((q,s)=>{const h={...q.headers}; h.host=T+':'+P; delete h['x-forwarded-host']; delete h['x-forwarded-proto']; delete h['x-forwarded-for']; delete h['accept-encoding'];
const r=https.request({host:T,port:P,method:q.method,path:q.url,headers:h},(u)=>{const rh={...u.headers}; if(rh.location) rh.location=rh.location.replace('https://'+T+':'+P,''); s.writeHead(u.statusCode,rh); u.pipe(s);});
r.on('error',e=>{s.writeHead(502);s.end('upstream '+e.message);}); q.pipe(r);}).listen(8769,()=>console.log('proxy on 8769'));
JS
pkill -f /tmp/p.mjs 2>/dev/null; nohup node /tmp/p.mjs > /tmp/p.log 2>&1 &
sleep 2; curl -s -o /dev/null -w "upstream %{http_code}\n" "http://127.0.0.1:8769/stnet/api/teams?room=37ad797b8dc3"
gh codespace ports visibility 8769:public -c "$CODESPACE_NAME" && echo PUBLIC_OK
