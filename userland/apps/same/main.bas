
#include once "stdlib.bi"
#include once "stdlib.bas"

#include once "system.bi"
#include once "gdi.bi"
#include once "file.bi"
#include once "slab.bi"
#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"

#include once "system.bas"
#include once "gdi.bas"
#include once "slab.bas"
#include once "file.bas"

#include once "tobject.bas"
#include once "font.bas"
#include once "fontmanager.bas"
#include once "gimage.bas"

dim shared mainWin as unsigned integer
dim shared drawableImage as GImage ptr
dim shared hauteur as unsigned integer
dim shared largeur as unsigned integer
dim shared Grille as unsigned integer ptr
dim shared SameList as unsigned integer ptr
dim shared Points as unsigned integer
dim shared GameFinished as integer

dim shared Couleurs(0 to 6) as unsigned integer


declare sub RedrawGrille()
declare sub NewGame()
declare sub drawOnMouseClick(elem as unsigned integer,param as unsigned integer)
declare sub GetSame(x as unsigned integer,y as unsigned integer)
declare sub AddSame(x as unsigned integer,y as unsigned integer,c as unsigned integer)
declare sub FaireTomber()
declare sub CheckIfAnyPossible()
sub MAIN(p as any ptr) 
    SlabInit()
    FontManager.Init()
    
	MainWin = GDIWindowCreate(19*32,13*32,@"SAME")
    drawableImage = cptr(GImage ptr,MAlloc(sizeof(GImage)))
    drawableImage->constructor(MainWin,0,0,19*32,13*32)
    drawableImage->OnMouseClick(@drawOnMouseClick)
    
    hauteur=13
    largeur=19
    Grille = 0
    SameList = 0
    Couleurs(0) = &hFF000000
    Couleurs(1) = &hFF0000FF
    Couleurs(2) = &hFF00FF00
    Couleurs(3) = &hFFFF0000
    Couleurs(4) = &hFFFF00FF
    Couleurs(5) = &hFF00FFFF
    Couleurs(6) = &hFFFFFF00
    ' 
    SameList = MALLOC(hauteur*largeur*sizeof(unsigned integer))
    NewGame()
	WaitForEvent()
end sub

sub drawOnMouseClick(elem as unsigned integer,param as unsigned integer)
    dim mx as short =cast(short, param shr 16)
    dim my as short =cast(short, param and &hFFFFFF)
    
    if GameFinished then
        EndCallBack()
        exit sub
    end if
    
   
    var x=mx\32
    var y=my\32
    if (x<Largeur and x>=0 and y<Hauteur and y>=0) then
        
        dim i as unsigned integer
        'clear the same list
        for i=0 to (largeur * hauteur)-1
            SameList[i]=&hFFFFFFFF
        next i
        
        GetSame(x,y) 'find the same nighbour cells
        if SameList[1]<>&hFFFFFFFF then 'if there is at least 2 same cells
            dim cpt as integer=0
            'set the cells to 0
            for i=0 to (largeur * hauteur)-1
                
                if SameList[i]=&hFFFFFFFF then exit for
                Grille[SameList[i]]=0
                cpt+=1
            next
            Points+=(cpt*cpt)
            FaireTomber()
            RedrawGrille()
            CheckIfAnyPossible()
        end if
    end if

    
    
	EndCallBack()
end sub   


sub NewGame()
    if (Grille<>0) then
        MFree(Grille)
    end if
    Grille = MAlloc(hauteur*largeur*sizeof(unsigned integer))
    for i as unsigned integer =0 to (hauteur*largeur)-1
        Grille[i]=NextRandomNumber(1,3)
    next i
    Points=0
    GameFinished=0
    RedrawGrille()
end sub

sub RedrawGrille()
    dim x as unsigned integer
    dim y as unsigned integer
    drawableImage->Clear(&hFF000000)
    
    
    
    for x as unsigned integer= 0 to largeur-1
        for y as unsigned integer =0 to hauteur -1
            var value=Grille[y*largeur+x]
            if (value<6) and (value>0) then
                drawableImage->FillRectangle(x*32,y*32,x*32+31,y*32+31,couleurs(value))
            end if
            drawableImage->DrawRectangle(x*32,y*32,x*32+31,y*32+31,&hFFFFFFFF)
        next y
    next x
    drawableImage->Flush()
end sub


sub CheckIfAnyPossible()
    dim x as unsigned integer
    dim y as unsigned integer
    dim i as unsigned integer
    dim trouver as  integer=0
    dim vide as  integer
    x=0
    vide=-1
    while x<largeur and trouver=0
        y=0
        while y<hauteur and trouver=0
            if Grille[y*largeur+x]<>0 then
                vide=0
                for i=0 to (largeur * hauteur)-1: SameList[i]=&hFFFFFFFF : next i
                GetSame(x,y)
                if SameList[1]<>&hFFFFFFFF then
                    trouver=-1
                end if
            end if
        y+=1
        wend
     x+=1
   wend
    if vide then
        DrawableImage->Clear(&hFF000000)
        drawableImage->Flush()
        MessageBoxShow(@"You won",@"info")
        NewGame()
    elseif not trouver then
        DrawableImage->Clear(&hFF000000)
        drawableImage->Flush()
        MessageBoxShow(@"You lost",@"info")
        NewGame()
    end if
end sub

sub GetSame(x as unsigned integer,y as unsigned integer)
    var myColor=Grille[y*largeur+x]
    if (myColor=0) then exit sub
    if (SameList[0]=&hFFFFFFFF) then SameList[0]=y*Largeur+x
    if (x>0) then
       if (Grille[y*largeur+(x-1)]=myColor) then AddSame(x-1,y,myColor)
    end if
    if (x<Largeur-1) then
        if (Grille[y*largeur+(x+1)]=myColor) then AddSame(x+1,y,myColor)
    end if
    
    if (y>0) then
       if (Grille[(y-1)*largeur+x]=myColor) then AddSame(x,y-1,myColor)
    end if
    if (y<Hauteur-1) then
        if (Grille[(y+1)*largeur+x]=myColor) then AddSame(x,y+1,myColor)
    end if
end sub

sub AddSame(x as unsigned integer,y as unsigned integer,c as unsigned integer)
    dim i as unsigned integer

    dim theVal as unsigned integer=y*Largeur+x
    for i=0 to (Largeur * Hauteur)-1
        if SameList[i]=theVal then exit sub
    next i
    for i=0 to (Largeur * Hauteur)-1
        if (SameList[i]=&hFFFFFFFF) then
            SameList[i]=theVal
            GetSame(x,y)
            exit sub
        end if
    next
end sub

sub FaireTomber()
    dim x as unsigned integer
    dim y as unsigned integer
    dim yy as unsigned integer
    dim xx as unsigned integer
    dim verif as unsigned integer=1
    
    for x=0 to largeur-1
        verif=1
        'while verif=1
            
            for y=hauteur-1 to 1 step -1
                verif=0
                if grille[y*largeur+x]=0 then
                    
                    for yy=y to 1 step -1
                        grille[yy*largeur+x]=grille[(yy-1)*largeur+x]
                        grille[(yy-1)*largeur+x]=0
                        if (grille[yy*largeur+x]<>0) then verif=1
                    next
                    
                end if
                y+=verif
            next
        'wend
    next
    
    for x=0 to largeur-1
        verif=0
        'verifier si la colone est vide
        for y=0 to hauteur -1
            if (grille[y*largeur+x]<>0) then
                verif=1
                exit for
            end if
        next
        if verif=0 then
            
            for xx=x to largeur-2
                for y=0 to hauteur-1
                    grille[y*largeur+xx]=grille[y*largeur+xx+1]
                    grille[y*largeur+xx+1]=0
                    if (grille[y*largeur+xx]<>0) then verif=1
                next
            next 
            x-=verif
        end if
    next
end sub
