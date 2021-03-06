Red/System [
	Title:   "Issue! datatype runtime functions"
	Author:  "Nenad Rakocevic"
	File: 	 %issue.reds
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2015 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/red-system/runtime/BSL-License.txt
	}
]

issue: context [
	verbose: 0
	
	load-in: func [
		str 	[c-string!]
		blk		[red-block!]
		return:	[red-word!]
		/local 
			cell [red-word!]
	][
		cell: as red-word! ALLOC_TAIL(blk)
		cell/header: TYPE_ISSUE							;-- implicit reset of all header flags
		cell/ctx: 	 global-ctx
		cell/symbol: symbol/make str yes
		cell/index:  -1
		cell
	]
	
	load: func [
		str 	[c-string!]
		return:	[red-word!]
	][
		load-in str root
	]
	
	push: func [
		w  [red-word!]
	][
		#if debug? = yes [if verbose > 0 [print-line "issue/push"]]
		
		w: word/push w
		set-type as red-value! w TYPE_ISSUE
	]
	
	;-- Actions --
	
	to: func [
		type	[red-datatype!]
		spec	[red-value!]
		return: [red-value!]
		/local
			issue [red-word!]
			str   [red-string!]
			bin   [red-binary!]
			s	  [series!]
			unit  [integer!]
	][
		#if debug? = yes [if verbose > 0 [print-line "issue/to"]]

		switch type/value [
			TYPE_WORD
			TYPE_SET_WORD
			TYPE_GET_WORD
			TYPE_LIT_WORD
			TYPE_REFINEMENT
			TYPE_ISSUE [
				spec/header: type/value
				as red-value! spec
			]
			TYPE_BINARY [
				issue: as red-word! spec
				str: as red-string! stack/push as red-value! symbol/get issue/symbol
				str/head: 0								;-- /head = -1 (casted from symbol!)
				s: GET_BUFFER(str)
				unit: GET_UNIT(s)
				
				bin: as red-binary! stack/arguments
				bin/head: 0
				bin/header: TYPE_BINARY
				bin/node: binary/decode-16 
					(as byte-ptr! s/offset) + (str/head << (log-b unit))
					string/rs-length? str
					unit
				stack/pop 1
				if null? bin/node [bin/header: TYPE_NONE]
				as red-value! bin
			]
			default  [
				fire [TO_ERROR(script bad-to-arg) type spec]
				null
			]
		]
	]
	
	mold: func [
		w	    [red-word!]
		buffer	[red-string!]
		only?	[logic!]
		all?	[logic!]
		flat?	[logic!]
		arg		[red-value!]
		part 	[integer!]
		indent	[integer!]
		return: [integer!]
	][
		#if debug? = yes [if verbose > 0 [print-line "issue/mold"]]

		string/append-char GET_BUFFER(buffer) as-integer #"#"
		word/form w buffer arg part - 1
	]
	
	compare: func [
		arg1	 [red-word!]							;-- first operand
		arg2	 [red-word!]							;-- second operand
		op		 [integer!]								;-- type of comparison
		return:	 [integer!]
	][
		#if debug? = yes [if verbose > 0 [print-line "issue/compare"]]
		
		if TYPE_OF(arg2) <> TYPE_ISSUE [RETURN_COMPARE_OTHER]	;@@ replace by ANY_WORD? when available
		word/compare arg1 arg2 op
	]
	
	init: does [
		datatype/register [
			TYPE_ISSUE
			TYPE_WORD
			"issue!"
			;-- General actions --
			null			;make
			null			;random
			null			;reflect
			:to
			INHERIT_ACTION	;form
			:mold
			null			;eval-path
			null			;set-path
			:compare
			;-- Scalar actions --
			null			;absolute
			null			;add
			null			;divide
			null			;multiply
			null			;negate
			null			;power
			null			;remainder
			null			;round
			null			;subtract
			null			;even?
			null			;odd?
			;-- Bitwise actions --
			null			;and~
			null			;complement
			null			;or~
			null			;xor~
			;-- Series actions --
			null			;append
			null			;at
			null			;back
			null			;change
			null			;clear
			null			;copy
			null			;find
			null			;head
			null			;head?
			null			;index?
			null			;insert
			null			;length?
			null			;move
			null			;next
			null			;pick
			null			;poke
			null			;put
			null			;remove
			null			;reverse
			null			;select
			null			;sort
			null			;skip
			null			;swap
			null			;tail
			null			;tail?
			null			;take
			null			;trim
			;-- I/O actions --
			null			;create
			null			;close
			null			;delete
			null			;modify
			null			;open
			null			;open?
			null			;query
			null			;read
			null			;rename
			null			;update
			null			;write
		]
	]
]
