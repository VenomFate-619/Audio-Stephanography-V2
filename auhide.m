
[filename, pathname] = uigetfile('*.wav','Select a file');        
[y,fs,nbits,opts]=wavread([pathname filename],[1 2]);


fid1=fopen([pathname filename],'r');


header=fread(fid1,40,'uint8=>char'); 


data_size=fread(fid1,1,'uint32');


[dta,count]=fread(fid1,inf,'uint16');   


fclose(fid1);

lsb=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg='Hello How are You';      %text message    %%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%




msg_double=double(msg);       
msg_bin=de2bi(msg_double,8);  
[m,n]=size(msg_bin);          
msg_bin_re=reshape(msg_bin,m*n,1);     
m_bin=de2bi(m,10)';
n_bin=de2bi(n,10)';
len=length(msg_bin_re);        


len_bin=de2bi(len,20)';       
                              

identity=[1 0 1 0 1 0 1 0]';
dta(1:8)=bitset(dta(1:8),lsb,identity(1:8));


dta(9:18)=bitset(dta(9:18),lsb,m_bin(1:10));
dta(19:28)=bitset(dta(19:28),lsb,n_bin(1:10));                              


dta(29:28+len)=bitset(dta(29:28+len),lsb,msg_bin(1:len)');


fid2=fopen('new2.wav','w');


fwrite(fid2,header,'uint8');
fwrite(fid2,data_size,'uint32');


fwrite(fid2,dta,'uint16');
fclose(fid2);
