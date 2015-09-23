
[filename, pathname] = uigetfile('*.wav','Select a file');        
[y,fs,nbits,opts]=wavread([pathname filename],[1 2]);


fid1=fopen([pathname filename],'r'); 
header=fread(fid1,40,'uint8=>char');
data_size=fread(fid1,1,'uint32');

[dta,count]=fread(fid1,inf,'uint16');

ans=fclose(fid1);

lsb=1;

identity=bitget(dta(1:8),lsb)';
if identity==[1 0 1 0 1 0 1 0]

    len_bin=zeros(20,1);
    m_bin=zeros(10,1);
    n_bin=zeros(10,1);

    m_bin(1:10)=bitget(dta(9:18),lsb);
    n_bin(1:10)=bitget(dta(19:28),lsb);
    
    len=bi2de(m_bin')*bi2de(n_bin');


    secmsg_bin=zeros(len,1);
    
    secmsg_bin(1:len)=bitget(dta(29:28+len),lsb);
    secmsg_bin_re=reshape(secmsg_bin,len/8,8);

    secmsg_double=bi2de(secmsg_bin_re); 
    secmsg=char(secmsg_double)'  
    end
