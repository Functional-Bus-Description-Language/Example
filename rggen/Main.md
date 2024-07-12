## Main

* byte_size
    * 256

|name|offset_address|
|:--|:--|
|[Subblock.Add](#Main-Subblock-Add)|0x00|
|[Subblock.Sum_Stream](#Main-Subblock-Sum_Stream)|0x08|
|[C1](#Main-C1)|0x0c|
|[C2](#Main-C2)|0x10|
|[C3](#Main-C3)|0x14|
|[S1](#Main-S1)|0x18|
|[S2](#Main-S2)|0x1c|
|[S3](#Main-S3)|0x20|
|[CA[10]](#Main-CA)|0x24<br>0x28<br>0x2c<br>0x30<br>0x34<br>0x38<br>0x3c<br>0x40<br>0x44<br>0x48|
|[SA[10]](#Main-SA)|0x4c<br>0x50<br>0x54<br>0x58<br>0x5c<br>0x60<br>0x64<br>0x68<br>0x6c<br>0x70|
|[Counter](#Main-Counter)|0x74|
|[Mask](#Main-Mask)|0x7c|
|[Version](#Main-Version)|0x80|

### <div id="Main-Subblock-Add"></div>Subblock.Add

* offset_address
    * 0x00
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|A|[19:0]|wo|0x00000||||
|B|[29:20]|wo|0x000||||
|C|[37:30]|wotrg|0x00||||
|Sum|[58:38]|ro|||||

### <div id="Main-Subblock-Sum_Stream"></div>Subblock.Sum_Stream

* offset_address
    * 0x08
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|Sum|[20:0]|rotrg|||||

### <div id="Main-C1"></div>C1

* offset_address
    * 0x0c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|C1|[6:0]|rw|0x00||||

### <div id="Main-C2"></div>C2

* offset_address
    * 0x10
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|C2|[8:0]|rw|0x000||||

### <div id="Main-C3"></div>C3

* offset_address
    * 0x14
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|C3|[11:0]|rw|0x000||||

### <div id="Main-S1"></div>S1

* offset_address
    * 0x18
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|S1|[6:0]|ro|||||

### <div id="Main-S2"></div>S2

* offset_address
    * 0x1c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|S2|[8:0]|ro|||||

### <div id="Main-S3"></div>S3

* offset_address
    * 0x20
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|S3|[11:0]|ro|||||

### <div id="Main-CA"></div>CA[10]

* offset_address
    * 0x24
    * 0x28
    * 0x2c
    * 0x30
    * 0x34
    * 0x38
    * 0x3c
    * 0x40
    * 0x44
    * 0x48
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|C|[7:0]|rw|0x00||||

### <div id="Main-SA"></div>SA[10]

* offset_address
    * 0x4c
    * 0x50
    * 0x54
    * 0x58
    * 0x5c
    * 0x60
    * 0x64
    * 0x68
    * 0x6c
    * 0x70
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|S|[7:0]|ro|||||

### <div id="Main-Counter"></div>Counter

* offset_address
    * 0x74
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|Value|[32:0]|ro|0x000000000||||

### <div id="Main-Mask"></div>Mask

* offset_address
    * 0x7c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|Mask|[15:0]|rw|0x0000||||

### <div id="Main-Version"></div>Version

* offset_address
    * 0x80
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|Version|[23:0]|rof|0x010102||||
