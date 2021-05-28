Enum DialogButton
    NoYes
    OkOnly
    OkCancel
end enum

Type Dialog extends TWindow field = 1
    DialogResult as integer
    th as any ptr
    Button1 as TButton ptr
    Button2 as TButton ptr
    DoClose as integer
    declare constructor()
    declare destructor()
    declare sub CloseDialog()
end type

Type MessageBox extends Dialog field =1
    Message as unsigned byte ptr
    
    declare constructor()
    declare destructor()
    
    declare static sub Show(message as unsigned byte ptr,title as unsigned byte ptr,btn as DialogButton,th as unsigned integer)
end type
declare sub DialogDestroy(e as dialog ptr)
declare sub MessageBoxDestroy(e as MessageBox ptr)
declare sub MessageBox_Redraw(elem as MessageBox ptr)
declare sub MessageBox_YesClicked(elem as TButton ptr)
declare sub MessageBox_NoClicked(elem as TButton ptr)
dim shared DialogTypeName as unsigned byte ptr=@"Dialog"
dim shared MessageBoxTypeName as unsigned byte ptr=@"MessageBox"