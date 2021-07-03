#Include once "Dialog.bi"


constructor dialog()
	this.RemoveChild(CloseButton)
    AssignNewObj(this.Button1,TButton)
    AssignNewObj(this.BUtton2,TButton)
    this.DoClose = 0
    this.CanManage = 1
    this.CanMove = 0
    Destruct = @DialogDestroy
    this.TypeName = DialogTypeName
end constructor

destructor dialog()
end destructor



constructor MessageBox()
    this.OnRedraw = @MessageBox_Redraw
    Destruct = @MessageBoxDestroy
    this.TypeName = MessageBoxTypeName
end constructor

destructor MessageBox()
    if message<>0 then
        Free(Message)
    end if
end destructor



sub DialogDestroy(e as dialog ptr)
    e->destructor()
end sub

sub MessageBoxDestroy(e as MessageBox ptr)
    e->destructor()
end sub

sub Dialog.CloseDialog()
   
    rootScreen->RemoveChild(@this)
    DestroyObj(@this)
end sub

sub MessageBox.Show(message as unsigned byte ptr,title as unsigned byte ptr,btn as DialogButton,th as unsigned integer)
    
    newobj(msg,MessageBox)
    dim result as integer
    var ml = strlen(message)+1
    msg->Message = MAlloc(ml)
    memcpy(msg->Message,message,ml)
    cptr(Dialog ptr,msg)->Title = title
    
    msg->SetSize(300,200)
    msg->SetPosition((XRES- msg->_width) shr 1,(YRES - msg->_height) shr 1)
    
    dim btnHeight as unsigned integer = 30
    dim btnWidth as unsigned integer = 75
    dim btnY1 as unsigned integer = msg->_height-msg->_paddingTop-btnHeight-20
    if (btn = NoYes) or (btn=OkCancel) then
        msg->AddChild(msg->Button1)
        msg->AddChild(msg->Button2)
        msg->Button1->OnClick = @MessageBox_NoClicked
        msg->Button2->OnClick = @MessageBox_YesClicked
        msg->Button1->SetSize(btnWidth,btnHeight)
        msg->Button2->SetSize(btnWidth,btnHeight)
        msg->Button1->SetPosition(10,btnY1)
        msg->Button2->SetPosition(msg->_width-msg->_paddingRight-20-btnWidth,btnY1)
        if (btn=NoYes) then
            msg->Button1->Text= @"No"
            msg->Button2->Text =@"Yes"
        elseif (btn = OkCancel) then
            msg->Button1->Text= @"Cancel"
            msg->Button2->Text =@"OK"
        end if
    elseif (btn=OkOnly) then
         msg->AddChild(msg->Button1)
        msg->Button1->OnClick = @MessageBox_YesClicked
        msg->Button1->SetSize(btnWidth,btnHeight)
        msg->Button1->SetPosition((msg->_width-btnWidth) shr 1,btnY1)
        msg->Button1->Text=@"OK"
    end if
    if (th<>0) then
        'dim t as Thread ptr = th
        msg->OwnerThread = th
        msg->Owner = th
        'cptr(thread ptr,msg->OwnerTHread)->HasModalVisible = -1
    end if
    rootScreen->AddChild(msg)
    
End sub

sub MessageBox_Redraw(elem as MessageBox ptr)
    
    'dim c1 as unsigned integer = &hFF29349C
    'dim c2 as unsigned integer = &hFF4A55BD
    'dim c3 as unsigned integer = &hFF00005A
    'elem->Clear(c1)
    'elem->DrawRectangle(0,0,elem->_width-1,elem->_height-1,&hFF000000)
    'elem->DrawRectangle(5,5,elem->_width-6,elem->_height-6,&hFF000000)
    'elem->FillRectangle(6,6,elem->_width-7,elem->_height-7,&hFFFFFFFF)
    TWindowRedraw(elem)
    elem->DrawTextMultiLine(elem->Message,0,elem->_paddingTop+30,&hFF000000,FontManager.ML,1, _
        elem->_width,HorizontalAlignment.Center)
end sub


sub MessageBox_YesClicked(elem as TButton ptr)
    dim dlg as MessageBox ptr =cptr(MessageBox ptr, elem->Parent)
    dlg->DialogResult =-1
    
    if (dlg->OwnerThread<>0) then
        ThreadWakeUP(dlg->OwnerThread,1,1)
    end if
    dlg->CloseDialog()
end sub

sub MessageBox_NoClicked(elem as TButton ptr)
     dim dlg as MessageBox ptr =cptr(MessageBox ptr, elem->Parent)
    dlg->DialogResult =0
    if (dlg->OwnerThread<>0) then
        ThreadWakeUP(dlg->OwnerThread,0,0)
    end if
    dlg->CloseDialog()
end sub