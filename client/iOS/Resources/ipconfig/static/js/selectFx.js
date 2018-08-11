/**
 * selectFx.js v1.0.0
 * http://www.codrops.com
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * Copyright 2014, Codrops
 * http://www.codrops.com
 */
( function( window ) {
	
	'use strict';

	/**
	 * based on from https://github.com/inuyaksa/jquery.nicescroll/blob/master/jquery.nicescroll.js
	 */
	function hasParent( e, p ) {
		if (!e) return false;
		var el = e.target||e.srcElement||e||false;
		while (el && el != p) {
			el = el.parentNode||false;
		}
		return (el!==false);
	};
	
	/**
	 * extend obj function
	 */
	function extend( a, b ) {
		for( var key in b ) { 
			if( b.hasOwnProperty( key ) ) {
				a[key] = b[key];
			}
		}
		return a;
	}

	/**
	 * SelectFx function
	 */
	function SelectFx( el, options ) {	
		this.el = el;
		this.options = extend( {}, this.options );
		extend( this.options, options );
		this._init();
	}

	/**
	 * SelectFx options
	 */
	SelectFx.prototype.options = {
		// if true all the links will open in a new tab.
		// if we want to be redirected when we click an option, we need to define a data-link attr on the option of the native select element
		newTab : true,
		// when opening the select element, the default placeholder (if any) is shown
		stickyPlaceholder : true,
		// callback when changing the value
		onChange : function( val ) { return false; }
	}

	/**
	 * init function
	 * initialize and cache some vars
	 */
	SelectFx.prototype._init = function() {
		// check if we are using a placeholder for the native select box
		// we assume the placeholder is disabled and selected by default
		var selectedOpt = this.el.querySelector( 'option[selected]' );
		this.hasDefaultPlaceholder = selectedOpt && selectedOpt.disabled;

		// get selected option (either the first option with attr selected or just the first option)
		this.selectedOpt = selectedOpt || this.el.querySelector( 'option' );
		console.log('this.selectedOpt')
		console.log(this.selectedOpt)

		// create structure
		this._createSelectEl();

		// all options
		this.selOpts = [].slice.call( this.selEl.querySelectorAll( 'li[data-option]' ) );
		
		// total options
		this.selOptsCount = this.selOpts.length;
		
		// current index
		//console.log(this.selOpts)
		this.current = this.selOpts.indexOf( this.selEl.querySelector( 'li.cs-selected' ) ) || -1;
		
		// placeholder elem
		
		this.selPlaceholder = this.selEl.querySelector( 'span.cs-placeholder' );
		this.yPlaceholder = this.selEl.querySelector( 'input.y-placeholder' );
		//this.addIpPlaceholder = this.selEl.querySelector('div.y-test-box');
		this.doubleBox = this.selEl.querySelector('div.double-input-box');
		// init events
		if(this.el.children.length !== 0){
			this._initEvents();
		}
		
	}

	/**
	 * creates the structure for the select element
	 */
	SelectFx.prototype._createSelectEl = function() {
		//这里有创建元素的函数
		var self = this, options = '', createOptionHTML = function(el) {
			var optclass = '', classes = '', link = '';

			if( el.selectedOpt && !this.foundSelected && !this.hasDefaultPlaceholder ) {
				classes += 'cs-selected ';
				this.foundSelected = true;
			}
			// extra classes
			if( el.getAttribute( 'data-class' ) ) {
				classes += el.getAttribute( 'data-class' );
			}
			// link options
			if( el.getAttribute( 'data-link' ) ) {
				link = 'data-link=' + el.getAttribute( 'data-link' );
			}

			if( classes !== '' ) {
				optclass = 'class="' + classes + '" ';
			}

			return '<li ' + optclass + link + ' data-option data-value="' + el.value + '"><span>' + el.textContent + "<div class = 'option-delete iconfont icon-close'></div></span></li>";

		};
		// console.log("this.el.children")
		if(this.el.children.length !== 0){
			[].slice.call( this.el.children ).forEach( function(el) {
				if( el.disabled ) { return; }
	
				var tag = el.tagName.toLowerCase();
	
				if( tag === 'option' ) {
					options += createOptionHTML(el);
				}
				else if( tag === 'optgroup' ) {
					options += '<li class="cs-optgroup"><span>' + el.label + '</span><ul>';
					[].slice.call( el.children ).forEach( function(opt) {
						options += createOptionHTML(opt);
					} )
					options += '</ul></li>';
				}
			} );
		}
		
		//yosang
		var ipinputHtml = "<div class='y-test-box'><input class='y-form-control-test y-address'></input><span>:</span><input class='y-form-control-test y-ipcontent y-ipcontent-one'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-two'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-three'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-four'></input></div>"
		this.ipinputEl = document.createElement('div');
		var opts_el = '<div class="cs-options"><ul>' + options + '</ul></div>';
		this.selEl = document.createElement( 'div' );
		this.selEl.className = this.el.className;
		this.selEl.tabIndex = this.el.tabIndex
		//yosang
		if(this.selectedOpt){
			// this.selEl.innerHTML = ipinputHtml;
			//this.selEl.innerHTML ="<input class='y-form-control y-placeholder ipselect' value='"+this.selectedOpt.textContent+"'></input><span class='cs-placeholder iconfont icon-down'></span>"+ opts_el;
			//this.selEl.innerHTML ="<div class='double-input-box'><input class='y-form-control y-placeholder ipselect' value='"+this.selectedOpt.textContent+"'></input><span class='cs-placeholder iconfont icon-down'></span></div>"+ opts_el;
			this.selEl.innerHTML = "<div class='double-input-box'><input class='col-md-11 col-sm-11 col-xs-11 col-xs-offset-1 col-md-offset-1 col-sm-offset-1 y-form-control y-placeholder ipselect' value='"+this.selectedOpt.textContent+"'></input><span class='col-xs-1 iconfont icon-down cs-placeholder'></span></div>"+ opts_el;
		}else{
			// this.selEl.innerHTML = ipinputHtml;
			//this.selEl.innerHTML ="<input class='y-form-control y-placeholder ipselect' value='' placeholder='ip配置'></input>"+ opts_el;
			//this.selEl.innerHTML ="<input class='col-md-10 col-sm-10 col-md-offset-1 col-sm-offset-1 y-input y-placeholder ipselect' value='' placeholder='ip配置'></input>"+ opts_el;
			this.selEl.innerHTML = "<div class='double-input-box'><input class='col-xs-12 y-form-control y-placeholder ipselect' value='ip配置'></input></div>"+ opts_el;
		}
		 
		//this.selEl.innerHTML = '<input><span class="cs-placeholder">' + this.selectedOpt.textContent + '</span></input>SS' + opts_el;
		this.el.parentNode.appendChild( this.selEl );
		this.selEl.appendChild( this.el );
	}

	/**
	 * initialize the events
	 */
	SelectFx.prototype._initEvents = function() {
		var self = this;

		// open/close select
		this.selPlaceholder.addEventListener( 'click', function(ev) {
			ev.stopPropagation()
			self._toggleSelect();
		} );

		// clicking the options
		this.selOpts.forEach( function(opt, idx) {
			opt.addEventListener( 'click', function() {
				self.current = idx;
				self._changeOption();
				// close select elem
				self._toggleSelect();
			} );
		} );

		// close the select element if the target it´s not the select element or one of its descendants..
		document.addEventListener( 'click', function(ev) {
			var target = ev.target;
			if( self._isOpen() && target !== self.selEl && !hasParent( target, self.selEl ) ) {
				self._toggleSelect();
			}
		} );

		// keyboard navigation events
		this.selEl.addEventListener( 'keydown', function( ev ) {
			var keyCode = ev.keyCode || ev.which;

			switch (keyCode) {
				// up key
				case 38:
					ev.preventDefault();
					self._navigateOpts('prev');
					break;
				// down key
				case 40:
					ev.preventDefault();
					self._navigateOpts('next');
					break;
				// space key
				case 32:
					ev.preventDefault();
					if( self._isOpen() && typeof self.preSelCurrent != 'undefined' && self.preSelCurrent !== -1 ) {
						self._changeOption();
					}
					self._toggleSelect();
					break;
				// enter key
				case 13:
					ev.preventDefault();
					if( self._isOpen() && typeof self.preSelCurrent != 'undefined' && self.preSelCurrent !== -1 ) {
						self._changeOption();
						self._toggleSelect();
					}
					break;
				// esc key
				case 27:
					ev.preventDefault();
					if( self._isOpen() ) {
						self._toggleSelect();
					}
					break;
			}
		} );


	}

	/**
	 * navigate with up/dpwn keys
	 */
	SelectFx.prototype._navigateOpts = function(dir) {
		if( !this._isOpen() ) {
			this._toggleSelect();
		}

		var tmpcurrent = typeof this.preSelCurrent != 'undefined' && this.preSelCurrent !== -1 ? this.preSelCurrent : this.current;
		
		if( dir === 'prev' && tmpcurrent > 0 || dir === 'next' && tmpcurrent < this.selOptsCount - 1 ) {
			// save pre selected current - if we click on option, or press enter, or press space this is going to be the index of the current option
			this.preSelCurrent = dir === 'next' ? tmpcurrent + 1 : tmpcurrent - 1;
			// remove focus class if any..
			this._removeFocus();
			// add class focus - track which option we are navigating
			classie.add( this.selOpts[this.preSelCurrent], 'cs-focus' );
		}
	}

	/**
	 * open/close select
	 * when opened show the default placeholder if any
	 */
	SelectFx.prototype._toggleSelect = function() {
		// remove focus class if any..
		//this._removeFocus();
		//有cs-active这个类
		if( this._isOpen() ) {
			classie.remove(this.selPlaceholder, 'icon-up')
			classie.add(this.selPlaceholder, 'icon-down')
			if( this.current !== -1 ) {
				this.yPlaceholder.value = this.selOpts[ this.current ].textContent;
			}
			classie.remove( this.selEl, 'cs-active' );
		}
		else {
		classie.remove(this.selPlaceholder, 'icon-down')
			classie.add(this.selPlaceholder, 'icon-up')
			classie.add( this.selEl, 'cs-active' );
			
		}
	}

	/**
	 * 切换input
	 */
	SelectFx.prototype._toggleInput = function() {
		//当前是待输入ip的状态
		if( this._isFocus() ) {
			classie.add( this.addIpPlaceholder, 'y-hide' );
			classie.remove( this.addIpPlaceholder, 'y-show' );
			// classie.add( this.csaddicon, 'y-show' );
			// classie.remove( this.csaddicon, 'y-hide' );
			classie.add( this.yPlaceholder, 'y-show' );
			classie.remove( this.yPlaceholder, 'y-hide' );
			if(this.selPlaceholder){
				classie.add( this.selPlaceholder, 'y-show' );
				classie.remove( this.selPlaceholder, 'y-hide' );
			}
			classie.add( this.selEl, 'cs-focus' );
		}
	}


	/**
	 * change option - the new value is set
	 */
	SelectFx.prototype._changeOption = function() {
		// if pre selected current (if we navigate with the keyboard)...
		if( typeof this.preSelCurrent != 'undefined' && this.preSelCurrent !== -1 ) {
			this.current = this.preSelCurrent;
			this.preSelCurrent = -1;
		}

		// current option
		var opt = this.selOpts[ this.current ];

		// update current selected value
		//this.selPlaceholder.textContent = opt.textContent;
		this.yPlaceholder.value = opt.textContent;
		
		// change native select element´s value
		this.el.value = opt.getAttribute( 'data-value' );

		// remove class cs-selected from old selected option and add it to current selected option
		var oldOpt = this.selEl.querySelector( 'li.cs-selected' );
		if( oldOpt ) {
			classie.remove( oldOpt, 'cs-selected' );
		}
		classie.add( opt, 'cs-selected' );

		// if there´s a link defined
		if( opt.getAttribute( 'data-link' ) ) {
			// open in new tab?
			if( this.options.newTab ) {
				window.open( opt.getAttribute( 'data-link' ), '_blank' );
			}
			else {
				window.location = opt.getAttribute( 'data-link' );
			}
		}

		// callback
		this.options.onChange( this.el.value );
	}

	/**
	 * returns true if select element is opened
	 */
	SelectFx.prototype._isOpen = function(opt) {
		return classie.has( this.selEl, 'cs-active' );
	}

	/**
	 * 返回当前input是否获取焦点
	 */
	SelectFx.prototype._isFocus = function(opt) {
		return classie.has( this.selEl, 'cs-focus' );
	}

	/**
	 * removes the focus class from the option
	 */
	SelectFx.prototype._removeFocus = function(opt) {
		var focusEl = this.selEl.querySelector( 'li.cs-focus' )
		if( focusEl ) {
			classie.remove( focusEl, 'cs-focus' );
		}
	}

	/**
	 * add to global namespace
	 */
	window.SelectFx = SelectFx;

} )( window );