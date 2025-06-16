# 5. Пример итогово XML файла для создания виртуальной сети

<network connections="1">
<br/>
<name>ovs-virtnet</name>
<br/>
<uuid>203616c8-c2ff-4f6b-ba14-dfb13951d492</uuid>
<br/>
<forward mode="bridge»/>
<br/>
<bridge name=»test-br»/>
<br/>
<virtualport type="openvswitch"/>
<br/>
<portgroup name="vlan-10">
<br/>
<vlan>
<br/>
<tag id="10"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="vlan-20">
<br/>
<vlan>
<br/>
<tag id="20"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="vlan-30">
<br/>
<vlan>
<br/>
<tag id="30"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="vlan-40">
<br/>
<vlan>
<br/>
<tag id="40"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="vlan-50">
<br/>
<vlan>
<br/>
<tag id="50"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="vlan-90">
<br/>
<vlan>
<br/>
<tag id="90"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
<portgroup name="trunk">
<br/>
<vlan trunk="yes">
<br/>
<tag id="30"/>
<br/>
<tag id="40"/>
<br/>
<tag id="50"/>
<br/>
</vlan>
<br/>
</portgroup>
<br/>
</network>
<br/>
