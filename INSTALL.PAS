 Titl формирование параметров "ПРИВЯЗКИ"
 Stack_sg segment para stack 'Stack'
          dw 32 dup(?)
 Stack_sg ends
 Data_sg  segment para 'Data'
          tie             db 5 dup(?)
          file_num        dw ?              ;файловый номер
          name_path       db 'c:\tie.96',0  ;путь
          boot_rec        db 512 dup(?)
          dir_rec         db 512 dup(?)
          oldest          dw ?
          younger         dw ?
          sector_dir      dw ? 
          sign            db 38h
                          db 26h
          error           db 'Ошибка !',$
          error05         db 'Переполнение оглавления !,$
          read_error_boot db 'Не могу прочитать Boot record !',$
          read_error_dir  db 'Не могу прочитать сектор первого каталога !',$
          write_error     db 'Не разрешена запись на диск',$
 Data_sg  ends
 Code_sg  segment para 'Code'
          Begin proc far
          Assume cs:Code_sg,ds:Data_sg,ss:Stack_sg,es:Data_sg
                push ds               ;инициализация
                sub ax,ax             ;  адреса
                push ax               ;  сегмента
                mov ax,Data_sg        ;  данных
                mov ds,ax
                call Read_sector
                mov ax,word ptr sign
                mov word ptr dir_rec+10,ax ;установить признак
                mov ah,03             ;запрос на запись
                mov al,01             ;  одного сектора
                lea bx,dir_rec
                mov ch,00             ;  на дорожку
                mov cl,byte ptr sector_dir
                mov dh,00             ;  стороны(головки)
                mov dl,02             ;  дисковода(С)
                int 13h
                jc error_write        ;ошибка записи на диск-сообщить
                call File_tie         ;сформировать файл "привязки"
          Begin endp
          Read_sector proc near
                      mov ah,02       ;запрос на чтение
                      mov al,01       ;  одного сектора
                      lea bx,boot_rec
                      mov ch,00       ;  дорожка
                      mov cl,01       ;  сектор
                      mov dh,00       ;  сторона(головка)
                      mov dl,02       ;  дисковод(С)
                      int 13h
                      jc error_boot   ;ошибка при чтении с диска-сообщить
                      mov al,byte ptr boot_rec+15 ;кол-во копий FAT
                      mov bx,word ptr boot_rec+21 ;размер FAT
                      mov cx,bx
                      cbw
                      mul bx         ;получить размер
                      mov oldest,dx  ;  копий FAT в DX:AX
                      mov younger,ax ;  и сохранить
                      mov ax,bx
                      cwd
                      add ax,younger ;учесть
                      mov younger,ax ;  размер
                      adc ax,oldest  ;  главной FAT
                      mov ax,dx
                      mov ax,younger
                      div 512        ;получить кол-во секторов под все FAT
                      inc ax         ;учесть нулевой сектор
                      mov sector_dir,ax ;сохранить первый сектор каталога
                      mov ah,02      ;запрос на чтение
                      mov al,01      ;  одного сектора
                      lea bx,dir_rec
                      mov ch,00      ;  дорожка
                      mov cl,byte ptr sector _dir ;сектор
                      mov dh,00      ;  сторона(головка)
                      mov dl,02      ;  дисковод(С)
                      int 13h
                      jc error_dir   ;ошибка чтения с диска-сообщить
         error_boot :
                      mov ah,09h
                      lea dx,read_error_boot
                      int 21h
                      ret
          error_dir :
                      mov ah,09h
                      lea dx,read_error_dir
                      int 21h
                      ret
        error_write :
                      mov ah,09h
                      lea dx,write_error
                      int 21h
                      ret
          Read_sector endp
          File_tie proc near
                   mov ah,3ch            ;запрос на создание файла
                   mov cx,1h             ;  только для чтения
                   lea dx,name_path
                   int 21h
                   jc l                  ;ошибка при создании -сообщить
                   mov file_num,ax       ;запомнить номер
                   jmp continue          ;    файла и продолжить
               l :
                   cmp ax,05
                   jmp mess05
                   mov ah.09
                   lea dx,error
                   int 21h
                   ret                   ;вернуться в ДОС
          mess05 :                       ;переполнение оглавления
                   mov ah,09h
                   lea dx,error05
                   int 21h
                   ret                   ;вернуться в ДОС
        continue :

                   mov ah,3eh            ;закрыть
                   mov bx,file_num       ;  идентификационный
                   int 21h               ;  файл
                   cmp ax,06             ;ошибка при закрытии ?
                   je error06             ;да-сообщить
                   ret                   ;нет-вернуться в ДОС
         error06 :
                   mov ah,09h
                   lea dx,error
                   int 21h
                   ret                   ;окончить работу
          File_tie endp