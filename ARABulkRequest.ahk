;This is an AutoHotKey script written to submit access 
;requests via the GUI of a proprietary resoure control system that facilitated no other bulk options. 
;It uses a community-developed Chrome library that allows you to send javascript commands to a debug instance of Chrome.
;Import a proprietary Chrome library
#Include C:\Working\AutoHotKey\Library\Chrome.ahk

ritm := "RITM0434452"
isWgMove := "yes"
;Can you use the override button in this case?
isWgOverride := "no"


;This stays blank always
aracompare := ""
;This grabs the chrome pagegrant derr
global page := Chrome.GetPageByTitle("Administer Resource Access")

Esc::ExitApp



;hit F1 with User LastFirstname, ARA name, and ARA RaId copied to see some serious shit.

F1::
    loop, parse, clipboard, `n, `r
    {
        ;grab ARA page
        ;chunk the clipboard line
        StringSplit, ara, A_LoopField, %A_Tab%
        araname := StrReplace(ara2, A_Space, "")
        araname := StrReplace(araname, "+", "")
        araname := StrReplace(araname, "_", "")
        araname := StrReplace(araname, "/", "")
        araname := StrReplace(araname, "-", "")
        araname := StrReplace(araname, ">", "")
        araname := StrReplace(araname, "&", "")
        araname := StrReplace(araname, ":", "")
        araname := StrReplace(araname, """", "")
        araname := StrReplace(araname, ",", "")
        araname := StrReplace(araname, "(", "")
        araname := StrReplace(araname, ")", "")
        araname := StrReplace(araname, ".", "")
        if (aracompare = "") {
            ;type in the ARA name
            page.Evaluate("document.querySelector('#resource').value = '"  ara2 "'")
            ;decalre you finished typing
            page.Evaluate("document.querySelector('#resource').dispatchEvent(new KeyboardEvent('keyup'))")
            sleep, 1000 
            ;click the edit button for the ARA to request
            
            page.Evaluate("document.querySelector('#" araname " > td.table_data_cell.text_left.sorting_1 > a.js-edit_resource').click()")
            sleep, 3000
            ;check if you're working on a wg move or user moves
            if (isWgMove = "no") {
                page.Evaluate("document.querySelector('#s2id_add_emid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 1000
                page.Evaluate("document.querySelector('#select2-drop').children[0].querySelector('[id^=s2id]').value = '"  ara1 "'")
                SendInput, {Space}
                sleep, 1000
                Send, `t
            } else {
                page.Evaluate("document.querySelector('#s2id_add_wgid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 200
                SendInput, % ara1
                sleep, 500
                ; SendInput, {Down}
                ; sleep, 50
                SendInput, {Tab}
                sleep, 100
                
            }
            
            ;set the comparison value for the previous if statement
            aracompare := ara2
            ;see if the ARA name is the same as last loop
            
        } else if (aracompare = ara2) {
            
            if (isWgMove = "no") {
                page.Evaluate("document.querySelector('#s2id_add_emid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 1000
                page.Evaluate("document.querySelector('#select2-drop').children[0].querySelector('[id^=s2id]').value = '"  ara1 "'")
                SendInput, {Space}
                sleep, 1000
                Send, `t
            } else {
                page.Evaluate("document.querySelector('#s2id_add_wgid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 1000
                SendInput, % ara1
                sleep, 500
                SendInput, {Tab}
                sleep, 100
            }
            aracompare := ara2
        } else {
            sleep 500
            page.Evaluate("document.querySelector('#add_snow_id').value = '" ritm "'")
            sleep 200
            if (isWgOverride = "no") {
                page.Evaluate("document.querySelector('#saveEntry').click()")
                sleep, 50
            } else {
                page.Evaluate("document.querySelector('#overrideEntry').click()")
                sleep, 50
            }
            SendInput, {Enter}
            sleep, 200
            try {
                send, {Enter}
                page.Evaluate("document.querySelector('body > div.wfa_modal.modal_transition_bottom.js-wf-modal.resource_access_modal.modal_transition_finish > span').click()")
            } catch {
                send, {Enter}
            }
            sleep, 1000
            ;type in the ARA name
            page.Evaluate("document.querySelector('#resource').value = '"  ara2 "'")
            ;decalre you finished typing
            page.Evaluate("document.querySelector('#resource').dispatchEvent(new KeyboardEvent('keyup'))")
            sleep, 1500
            ;click the edit button for the ARA to request
            page.Evaluate("document.querySelector('#" araname " > td.table_data_cell.text_left.sorting_1 > a.js-edit_resource').click()")
            sleep, 2000
            if (isWgMove = "no") {
                page.Evaluate("document.querySelector('#s2id_add_emid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 1000
                page.Evaluate("document.querySelector('#select2-drop').children[0].querySelector('[id^=s2id]').value = '"  ara1 "'")
                SendInput, {Space}
                sleep, 1000
                Send, `t
            } else {
                page.Evaluate("document.querySelector('#s2id_add_wgid_sel > a').dispatchEvent(new MouseEvent('mousedown'))")
                sleep, 1000
                SendInput, % ara1
                sleep, 500
                SendInput, {Tab}
                sleep, 500
            }
            ;set the comparison value for the previous if statement
            aracompare := ara2
           
        }
    }
    sleep, 1000
    page.Evaluate("document.querySelector('#add_snow_id').value = '" ritm "'")
    sleep 200
    if (isWgOverride = "no") {
        page.Evaluate("document.querySelector('#saveEntry').click()")
        sleep, 50
    } else {
        page.Evaluate("document.querySelector('#overrideEntry').click()")
        sleep, 50
    }
    SendInput, {Enter}
    sleep, 200
    try {
        send, {Enter}
        page.Evaluate("document.querySelector('body > div.wfa_modal.modal_transition_bottom.js-wf-modal.resource_access_modal.modal_transition_finish > span').click()")
    } catch {
        send, {Enter}
    }
    aracompare := ""
return

