export var_proxy="test"
export var_servername="test"
export var_vhostname="test"

echo "$(./transfer.py ./config-revproxy.txt > /tmp/test.conf)"

#sed -i '/#dhparam/a "$(echo "$(./transfer.py ./config-revproxy.txt)")"' /tmp/$var_vhostname.conf

#sed -i "/dhparam/a $(echo "$(./transfer.py ./config-revproxy.txt)")" /tmp/$var_vhostname.conf

#sed -i "/#dhparam/a $(echo "$(./transfer.py ./config-revproxy.txt)")" /tmp/$var_vhostname.conf

#sed -i '/#dhparam/a $(echo "$(./transfer.py ./config-revproxy.txt)")' /tmp/$var_vhostname.conf

#sed -i "/#dhparam/a $(echo "$(./transfer.py ./config-revproxy.txt)")" /tmp/$var_vhostname.conf

#echo "$(./transfer.py ./config-revproxy.txt)" >> /tmp/$var_vhostname.conf
