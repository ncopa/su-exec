/*
 * Copied from https://github.com/wc-duck/dbgtools/blob/master/include/dbgtools/static_assert.h
 */
/*
	dbgtools - platform independent wrapping of "nice to have" debug functions.

	version 0.1, october, 2013
	
	https://github.com/wc-duck/dbgtools

	Copyright (C) 2013- Fredrik Kihlander

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.

	Fredrik Kihlander
 */

#ifndef DBGTOOLS_STATIC_ASSERT_INCLUDED
#define DBGTOOLS_STATIC_ASSERT_INCLUDED

/**
 * Compile-time check that condition is true, if false a compile-time error will be generated.
 * This macro tries to use a built in variant of static assert to generate as good errors as possible but fall back to a generic implementation
 * if that is not available.
 *
 * @note msg will be ignored and an "as good as possible" message will get displayed instead if compiler has no built in support for static assert.
 *
 * @note macro do unfortunately not work within structs in its c-implementation =/
 * @note on compilers that do not support __COUNTER__ static_assert_counter.h will be used to generate a counter. This however forces the user to include
 *       static_assert.h in each file where it is used ( as should be done anyways ).
 *
 * @example STATIC_ASSERT( sizeof( int ) == 4, "size of int is not 4!" );
 */
#define STATIC_ASSERT(cond, msg)
#undef STATIC_ASSERT

// ... clang ...
#if defined( __clang__ )
#  if defined( __cplusplus ) && __has_feature(cxx_static_assert)
#    define STATIC_ASSERT( cond, msg ) static_assert( cond, msg )
#  elif __has_feature(c_static_assert)
#    define STATIC_ASSERT( cond, msg ) _Static_assert( cond, msg )
#  endif

// ... msvc ...
#elif defined( _MSC_VER ) && ( defined(_MSC_VER) && (_MSC_VER >= 1600) )
#    define STATIC_ASSERT( cond, msg ) static_assert( cond, msg )

// ... gcc ...
#elif defined( __cplusplus )
#  if __cplusplus >= 201103L || ( defined(_MSC_VER) && (_MSC_VER >= 1600) )
#    define STATIC_ASSERT( cond, msg ) static_assert( cond, msg )
#  endif
#elif defined( __STDC__ )
#  if defined( __STDC_VERSION__ )
#    if __STDC_VERSION__ >= 201112L
#      define STATIC_ASSERT( cond, msg ) _Static_assert( cond, msg )
#    else
#      define STATIC_ASSERT( cond, msg ) _Static_assert( cond, msg )
#    endif
#  endif
#endif

/* if we couldn't detect a builtin static assert, lets define one! */
#ifndef STATIC_ASSERT
#  if defined( __COUNTER__ )
#    define DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO(line) DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO1(__COUNTER__,line)
#  else
#    define DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO(line) DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO1(DBG_TOOLS_STATIC_ASSERT_COUNTER,line)
#  endif
#  define DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO1(count,line) DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO2(count,line)
#  define DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO2(count,line) static_assert_##count##_at_line_##line
#
#  if defined( _MSC_VER )
#    if defined( __cplusplus )
       template<bool> struct DBG_TOOLS_STATIC_ASSERT_IMPL;
       template<> struct DBG_TOOLS_STATIC_ASSERT_IMPL<true> {};
#      define STATIC_ASSERT( cond, msg ) struct DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO( __LINE__ ) { DBG_TOOLS_STATIC_ASSERT_IMPL<(cond)> a; }
#    else
#      define STATIC_ASSERT( cond, msg ) enum { DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO( __LINE__ ) = 1 / (!!(cond)) }
#    endif
#  else
#    define STATIC_ASSERT( cond, msg ) typedef char DBGTOOLS_STATIC_ASSERT_MACRO_TOKENS_DO( __LINE__ )[ (cond) ? 1 : -1 ] __attribute__ ((unused))
#  endif
#endif

#endif

// This inclusion is outside the ifdef on purpose. 
#if !defined( __COUNTER__ )
#  include "static_assert_counter.h"
#endif
