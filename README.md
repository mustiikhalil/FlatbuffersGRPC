# GRPCFlatbuffers

Note: It's important to wrap the Array with a container object since we will be accessing the `BytesBuffer`  directly! 

Example: 
```
table Feature {
 name: string;
 p: Point;
}

table features {
 features: [Feature];
}
```
