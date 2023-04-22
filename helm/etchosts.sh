#!/bin/bash
bash ~/bin/update_dns.sh
sleep 2
tmpfile=`mktemp`

ingress_ip=`kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
l=""
for i in `kubectl -n istio-system get virtualservice | grep -v NAME | awk '{print $1}'`; do
    hname=`kubectl -n istio-system get virtualservice ${i} -o jsonpath='{.spec.hosts[0]}'`
    echo ${hname}
    sudo sed -i "/${hname}/d" /etc/hosts
    l=`echo -n ${l} ${hname}`
done

ssh 10.2.1.40 'cat /etc/pihole/custom.list' > ${tmpfile}
echo "${ingress_ip} $l" >> ${tmpfile}

l=""
for i in `kubectl -n open5gs get virtualservice | grep -v NAME | awk '{print $1}'`; do
    hname=`kubectl -n open5gs get virtualservice ${i} -o jsonpath='{.spec.hosts[0]}'`
    echo ${hname}
    sudo sed -i "/${hname}/d" /etc/hosts
    l=`echo -n ${l} ${hname}`
done
echo "${ingress_ip} $l" >> ${tmpfile}

cat ${tmpfile} | ssh 10.2.1.40 'cat > /tmp/tmppyhole'
ssh 10.2.1.40 'sudo cp /tmp/tmppyhole /etc/pihole/custom.list'
ssh 10.2.1.40 'pihole restartdns'
sleep 2