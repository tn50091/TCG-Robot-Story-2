*** Settings ***

Library                SSHLibrary
Suite Setup            Open Connection And log In
Suite Teardown         Close All Connections


*** Variables ***

${Table1}           ZUTBLCOLPRJ
${Table2}           ZUTBLCOLSPRJ
${Date}             20180313
${Dir}              /gsbpvt
${HostIP}           10.251.87.86
${HostUser}         pvtadm
${HostPass}         ${HostUser}
${File1}            ${Table1}_${Date}.txt
${File2}            ${Table2}_${Date}.txt
${LocalPath}        C:/Users/UX305/Desktop
${CMSPath}          ${Dir}/spool/extract/CMS
${CBSPathTo}        ${Dir}/spool/extract/CMS/ToCMS
${FTPPathTo}        CMS/ToCMS
${FTPIP}            10.20.6.58
${FTPHostUser}      cbsist


*** Test Cases ***

Generate file CBS->CMS (ZUTBLCOLPRJ,ZUTBLCOLSPRJ)
    [Documentation]    Run Procedure ZLOREXTRACT, Extract table ZUTBLCOLPRJ,ZUTBLCOLSPRJ
    Write      dm
    Write      D EXTRACTALL^ZLOREXTR
    Write      H
    Sleep      2s
    file should exist  ${CBSPathTo}/${File1}
    file should exist  ${CBSPathTo}/${File2}

Compare Database with File (ZUTBLCOLPRJ)
    [Documentation]    Compare data ZUTBLCOLPRJ exclude header/trailer
    Run SQL ZUTBLCOLPRJ
    ${output}=      Execute Command  sed -n '$=' ${CBSPathTo}/${File1} 
    ${head-trail}=     set variable    ${2}
    ${output}=     Evaluate    ${output}-${head-trail}
    ${output2}=      Execute Command  sed -n '$=' ${CMSPath}/${File1}
    ${output2}=     Convert To Integer  ${output2}
    Should Be Equal    ${output}   ${output2}
    log To Console      \n${output}
    log To Console      \n${output2}

Compare Database with File (ZUTBLCOLSPRJ)
    [Documentation]    Compare data ZUTBLCOLSPRJ exclude header/trailer
    Run SQL ZUTBLCOLSPRJ
    ${output}=      Execute Command  sed -n '$=' ${CBSPathTo}/${File2}
    ${head-trail}=     set variable    ${2}
    ${output}=     Evaluate    ${output}-${head-trail}
    ${output2}=      Execute Command  sed -n '$=' ${CMSPath}/${File2}
    ${output2}=     Convert To Integer  ${output2}
    Should Be Equal    ${output}   ${output2}
    log To Console      \n${output}
    log To Console      \n${output2}

FTP file ZUTBLCOLPRJ to CMS
    [Documentation]    Upload file ZUTBLCOLPRJ to ftp
    ${rc} =  Execute Command  ${Dir}/Batch/LOR_PUT.sh ${Dir} ${Table1}  return_stdout=False   return_rc=True
    Should Be Equal As Integers     ${rc}   0   # succeeded
    Sleep   2s

FTP file ZUTBLCOLSPRJ to CMS
    [Documentation]    Upload file ZUTBLCOLSPRJ to ftp
    ${rc} =  Execute Command  ${Dir}/Batch/LOR_PUT.sh ${Dir} ${Table2}  return_stdout=False   return_rc=True
    Should Be Equal As Integers     ${rc}   0   # succeeded
    Sleep   2s


*** Keywords ***

Open Connection And Log In
   Open Connection    ${HostIP}
   Login    ${HostUser}    ${HostPass}

Run SQL ZUTBLCOLPRJ
    #Access to GTM
    Write      dm
    Write      D EXPORT^SQLOADER("select PROJCD,DESC from ZUTBLCOLPRJ","${CMSPath}/${File1}",0,124)
    Read until  GTM>
    Write   H

Run SQL ZUTBLCOLSPRJ
    #Access to GTM
    Write      dm
    Write      D EXPORT^SQLOADER("select PROJCD,SUBCD,DESC,STARTDT,ENDDT,MAXALOC from ZUTBLCOLSPRJ","${CMSPath}/${File2}",0,124)
    Read until  GTM>
    Write   H
