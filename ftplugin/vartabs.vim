" VARTABS.VIM: (global plugin) Tabstops at arbitrary positions
" Last Change:	2014-07-26_00:21:09
" Maintainer:	Michael Fitz   <mfitz@aon.at>
" Version:	2.0
"
" Installation:
"   Just copy into the 'plugin'-folder
"
" Usage:
"   In a filetype-plugin enter this line:
"   :call VarTab_SetStops("a,b,c,...,n")
"   where a,b,... are ascending tabstop-positions you want
"    (eg. when dealing with /370-Assembler: "10,16,71"
"   
" Function:
"   Maps <TAB> and <S-TAB> to jump to the specified positions
"
" Changelog:
"   2014-07-26_00:21:21
"     Allow lists as argument too preserving backwards-compatibility

let b:Pos_Count=0

:function! VarTab_SetStops(aaa)
let stoplist=a:aaa
" Determining type of argument
if (type(stoplist)==type("")) "old string argument
"echo "OLD STRING"  
" Clearing old Positions
let b:Pos_Count=0
let b:Pos=[]
" Making a new Poslist
let z=stoplist.','  "will make parsing easier
let cnt=0 "Counter
while(z!="")
  " echo z
  let i=matchend(z,'\s*\d\+\s*,')
  if(i<0)
    break
  endif
  let cnt=cnt+1
  let z1=strpart(z,0,i-1)
  let z1=matchstr(z1,'\d\+')
  let xpos=0+z1
  let b:Pos+=[xpos]
  let z=strpart(z,i)
endwhile
elseif (type(stoplist)==type([])) "arguments as list
"echo "NEW LIST"  
  let b:Pos=stoplist
  let cnt=len(b:Pos)
endif  
" checking validation
let b:Pos_Count=cnt "Number of Positions
let ii=0
let vg1=0
while(ii<b:Pos_Count)
  if(b:Pos[ii]<vg1)
    let msg="Tabstop #" . (ii+1) . ' (' . b:Pos[ii] . ') is less than preceding stop (' . vg1 . ')'
    echohl WarningMsg
    echo msg
    echohl None
    let b:Pos_Count=-cnt "To remember and invalidate together
    return
  endif
  let vg1=b:Pos[ii]
  let ii+=1
endwhile
let ii=0
let z=b:Pos_Count . ' tabstops set at positions '
let zc=''
while(ii<b:Pos_Count)                                       
  let z=z.zc.b:Pos[ii]
  let ii=ii+1
  let zc=','
endwhile
echo z
:nmap <silent> <buffer> <TAB> :call <SID>VarTab_DoStops(1)<CR>
:imap <silent> <buffer> <TAB> <C-O>:call <SID>VarTab_DoStops(1)<CR>
:nmap <silent> <buffer> <S-TAB> :call <SID>VarTab_DoStops(-1)<CR>
:imap <silent> <buffer> <S-TAB> <C-O>:call <SID>VarTab_DoStops(-1)<CR>
:endfun

fun! s:VarTab_DoStops(Dir)
  if b:Pos_Count<=0 "No stops present
    return
  endif
  let l1=line(".")
  let c1=col(".")
  let c3=col("$")
  if(a:Dir>0)
    let c2=b:Pos[b:Pos_Count-1]  "Last position if no other found
    let ii=0
    while(ii<b:Pos_Count)
      let ip=b:Pos[ii]
      if(c1<ip)                                                                 
        let c2=ip
        break
      endif
      let ii=ii+1
    endwhile
  else
    let c2=1  "start of line
    let ii=b:Pos_Count-1
    while(ii>=0)
      let ip=b:Pos[ii]
      if(c1>ip)                                                                 
        let c2=ip
        break
      endif
      let ii=ii-1
    endwhile
  endif
  " echo "c1=" . c1 .", l1=" . l1 . ", c2=" . c2 . ", c3=" . c3             
  if(c2>c3)                                                                 
    let z1=getline(l1)                                                    
    while(strlen(z1)<c2)                                                    
      let z1=z1 . "                      "
    endwhile
    let z1=strpart(z1,0,c2-1)
    let sve=&ve
    set ve=
    call setline(l1,z1)
    let &ve=sve
  endif                                                                 
  call cursor(l1,c2)
:endfun

" :call VarTab_SetStops("1,22, 33 , 44  , 60")                          
