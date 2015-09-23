function varargout = audiostegano(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @audiostegano_OpeningFcn, ...
                   'gui_OutputFcn',  @audiostegano_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function audiostegano_OpeningFcn(hObject, eventdata, handles, varargin)



handles.output = hObject;
handles.fname='';
handles.pname='';
set(handles.pushbutton2,'enable','off');
set(handles.text2,'string','Select a wav file in which you want to hide text');
% Update handles structure
guidata(hObject, handles);





function varargout = audiostegano_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pushbutton1_Callback(hObject, eventdata, handles)

value1=get(handles.radiobutton1,'value');
value2=get(handles.radiobutton2,'value');
if value1==1
    
    [handles.fname, handles.pname] = uigetfile('*.wav','Select a file');        
    set(handles.pushbutton2,'enable','on'); 
    guidata(hObject, handles); %update handle structure

end
if value2==1
     set(handles.pushbutton2,'enable','off'); 
     [filename, pathname] = uigetfile('*.wav','Select a file');        
     [y,fs,nbits,opts]=wavread([pathname filename],[1 2]);
     %open the file with hidden text
     fid1=fopen([pathname filename],'r'); 
     header=fread(fid1,40,'uint8=>char');
     data_size=fread(fid1,1,'uint32');
     %read the wave data samples
     [dta,count]=fread(fid1,inf,'uint16');
     %close the file,only wav data samples are sufficient for extracting the text
     fclose(fid1);
     
     lsb=1;

     identity=bitget(dta(1:8),lsb)';
     if identity==[1 0 1 0 1 0 1 0]
       %extract the length of text from first 9th to 28th wav data samples 
       len_bin=zeros(20,1);
       m_bin=zeros(10,1);
       n_bin=zeros(10,1);

       m_bin(1:10)=bitget(dta(9:18),lsb);
       n_bin(1:10)=bitget(dta(19:28),lsb);
       %convert the length to decimal
       %len=bi2de((len_bin)');
       m=bi2de(m_bin');
       n=bi2de(n_bin');
       len=m*n*8;
       
       secmsg_bin=zeros(len,1);
       %extract the lsb from wave data sample
       secmsg_bin(1:len)=bitget(dta(29:28+len),lsb);
       secmsg_bin_re=reshape(secmsg_bin,len/8,8);

       secmsg_double=bi2de(secmsg_bin_re); %convert it to decimal

       secmsg=char(reshape(secmsg_double,m,n));  %convert to char(ASCII)
       %size(secmsg)
       %secmsg=reshape(secmsg,m,n/8);
       set(handles.edit1,'string',secmsg);
       
     else
     msgbox('File has no hidden text','Empty');
     end
end
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg=get(handles.edit1,'string');


if length(msg)==0
     msgbox('Please type some text','Empty');
else
    [y,fs,nbits,opts]=wavread([handles.pname handles.fname],[1 2]);
    %open a wav file for hidding text
    fid1=fopen([handles.pname handles.fname],'r');
    
    %first 40 bytes make wav header,store the header
    header=fread(fid1,40,'uint8=>char'); 
    
    %41st byte to 43rd byte,length of wav data samples 
    data_size=fread(fid1,1,'uint32');
    
    %copy the 16 bit wav data samples starting from 44th byte
    [dta,count]=fread(fid1,inf,'uint16');   
    
    %close the file, only wav data samples are sufficient to hide the text 
    fclose(fid1);
    
    lsb=1;

    
    msg=get(handles.edit1,'string');    %get text message from editbox
    [ro,co]=size(msg);
    if ( (ro*co*8+28) > count )
      msgbox('Message too big, select small message','Empty');
    else
        [m_msg,n_msg]=size(msg);
        msg_double=double(msg);             %convert it to double
        
        msg_bin=de2bi(msg_double,8);        %then convert message to binary
        [m,n]=size(msg_bin);                %size of message binary
        msg_bin_re=reshape(msg_bin,m*n,1);  %reshape the message binary in a column vector   
        m_bin=de2bi(m_msg,10)';          %
        n_bin=de2bi(n_msg,10)';          %
        len=length(msg_bin_re);       %length of message binary 


        len_bin=de2bi(len,20)';       %convert the length to binary

        %hide identity in first 8 wav data samples.
        identity=[1 0 1 0 1 0 1 0]';
        dta(1:8)=bitset(dta(1:8),lsb,identity(1:8));

        %hide binary length of message from 9th to 28 th sample 
        dta(9:18)=bitset(dta(9:18),lsb,m_bin(1:10));
        dta(19:28)=bitset(dta(19:28),lsb,n_bin(1:10));                              
        %hide the message binary starting from 29th position of wave data samples
        dta(29:28+len)=bitset(dta(29:28+len),lsb,msg_bin(1:len)');


        randname=num2str(randint(1,1,[1 2000]));

        %open a new wav file in write mode
        fid2=fopen(['new' randname '.wav'],'w');

        %copy the header of original wave file
        fwrite(fid2,header,'uint8');
        fwrite(fid2,data_size,'uint32');

        %copy the wav data samples with hidden text in new file
        fwrite(fid2,dta,'uint16');
        fclose(fid2);

        msgbox(['Your text is hidden in  new' randname '.wav file'],'');
        set(hObject,'enable','off');
    end
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)

set(hObject,'value',1);
set(handles.text2,'string','Select a wav file in which text is already hidden');
set(handles.pushbutton2,'enable','off'); 


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)

set(hObject,'value',1);
set(handles.text2,'string','Select a wav file in which you want to hide text');

