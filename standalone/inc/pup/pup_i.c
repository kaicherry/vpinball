/*** Autogenerated by WIDL 9.8 from PUP.idl - Do not edit ***/

#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
    DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#elif defined(__cplusplus)

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
    EXTERN_C const type DECLSPEC_SELECTANY name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#else

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
    const type DECLSPEC_SELECTANY name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif

#ifdef __cplusplus
extern "C" {
#endif

MIDL_DEFINE_GUID(IID, LIBID_PUP, 0xd50f2477, 0x84e8, 0x4ced, 0x94,0x09, 0x37,0x35,0xca,0x67,0xfd,0xe3);
MIDL_DEFINE_GUID(IID, IID_IPinDisplay, 0x7a2ccc8d, 0x6aed, 0x43be, 0x8e,0xbd, 0x4d,0x2c,0xd8,0x02,0xf4,0xce);
MIDL_DEFINE_GUID(CLSID, CLSID_PinDisplay, 0x88919fac, 0x00b2, 0x4aa8, 0xb1,0xc7, 0x52,0xad,0x65,0xc4,0x76,0xd3);

#ifdef __cplusplus
}
#endif

#undef MIDL_DEFINE_GUID
