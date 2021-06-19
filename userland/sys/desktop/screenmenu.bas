
constructor AppRegistration()
    Title = 0
end constructor

destructor AppRegistration()
    Thread = 0
    Process = 0
    prevApp = 0
    nextApp = 0
    Title = 0
end destructor

sub ScreenMenu_Init()
    
    var MenuSkin = Skin.Create(@"SYS:/RES/MENU.BMP",1,10,10,16,15)
    var MenuBtnSkin = Skin.Create(@"SYS:/RES/MENUBTN.BMP",3,10,10,16,15)
    MenuSkin->ApplyColor(wincolor,0)
    MenuBtnSkin->ApplyColor(wincolor,0)
    FirstRegisteredApp = 0
    LastRegisteredApp = 0
    CurrentApp = 0
    mainMenu = new GDIBase()
    mainMenu->SetPosition(0,0)
    mainMenu->SetSize(XRes,32)
    MenuSkin->DrawOn(mainMenu,0,0,0,mainMenu->_Width ,mainMenu->_Height,&hFFFF0000,0)
    RootScreen->AddChild(mainMenu)
    
    mainMenuButton = new TButton()
    mainMenuButton->SetPosition(0,0)
    mainMenuButton->SetSize(150,32)
    mainMenuButton->FGColor = &hFFFFFFFF
    mainMenuButton->_Skin = MenuBtnSkin
    mainMenu->AddChild(mainMenuButton)
end sub

sub ProcessActivate(proc as unsigned integer)
    var app = FirstRegisteredApp
    if (proc=0) then
        mainMenuBUtton->Text =@""
        CurrentApp = 0
        exit sub
    end if
    
    while app<> 0
        if (app->Process = proc) then 
            mainMenuBUtton->Text = app->Title
            CurrentApp = app
            exit sub
        end if
        app = app->NextApp
    wend
end sub

sub ProcessSetTitle(proc as unsigned integer,t as unsigned byte ptr)
    var app = FirstRegisteredApp
    while app<> 0
        if (app->Process = proc) then 
            if (app->Title=0) then
                app->Title = t
                if (app=CurrentApp) then
                    mainMenuBUtton->Text = app->Title
                end if
            end if
            exit sub
        end if
        app = app->NextApp
    wend
end sub

sub ProcessRegister(proc as unsigned integer,th as unsigned integer)
    
    var app = FirstRegisteredApp
    while app<> 0
        if (app->Process = proc) then exit sub
        app = app->NextApp
    wend
    
    
    app = new AppRegistration()
    app->Thread= th
    app->Process = proc
    app->NextApp = 0
    if (LastRegisteredApp<>0) then
        LastRegisteredApp->NextApp = app
    else
        FirstRegisteredApp = app
    end if
    app->PrevApp = LastRegisteredApp
    LastRegisteredApp =app
    
end sub

sub ProcessUnregister(proc as unsigned integer)
    
    if (proc=0) then exit sub
    
    var app = FirstRegisteredApp
    while app <> 0
        var n = app ->NextApp
        if (app ->Process = proc) then
            if (app ->PrevApp<>0) then 
                app ->PrevApp->NextApp = app ->NextApp
            else
                FirstRegisteredApp = app ->NextApp
            end if
            
            if (app ->NextApp<>0) then 
                app ->NextApp->PrevApp = app ->PrevApp
            else
                LastRegisteredApp = app ->PrevApp
            end if
            delete app 
            exit sub
            
        end if
        app  = n
    wend
end sub