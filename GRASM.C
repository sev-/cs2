main()
{
	asm {
		mov		ax, 10h
		int		10h
		mov		dx, 3ceh
		mov		ax, 0500h
		call	@out_dx
		mov		ax, 0a000h
		mov		es, ax
		mov		cx, 28000
		mov		dx, 03ceh
		mov		ax, 08ffh
		call	@out_dx
  }
  loop1:;
  asm {
		mov		dx, 03c4h
		mov		ah, 02
		mov		al, bl
		shl		al, 1
		and		al, 0fh
		call	@out_dx
		mov		bx, cx
		mov		al, es:[bx]
		mov		al, 0ffh
		mov		es:[bx], al
		loop	loop1
		mov		ah, 8
		int		21

		mov		dx, 03ceh
		mov		ax, 0502h
		call    @out_dx
		mov		cx, 28000
		mov		dx, 03ceh
		mov		ax, 08ffh
		call	@out_dx
  }
  loop2:;
  asm {
		mov		bx, cx
		mov		al, es:[bx]
		mov		al, bl
		shr		al, 1
		and		al, 0ffh
		mov		es:[bx], al;
		loop	loop2
		mov		ah, 8
		int		21h
		mov		ax, 0003h
		int		10h
		jmp		stop
@out_dx:
		xchg	al, ah
		out		dx, al
		inc		dx
		xchg	al, ah
		out		dx, al
		ret
  }
  stop:
  return 0;
}