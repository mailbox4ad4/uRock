#ifndef __DELAY_H__
#define __DELAY_H__

#include "base-effect.h"

struct Delay_t{
    struct Effect_t parent;
    struct parameter_t delayTime;
    struct parameter_t attenuation;
    uint32_t baseAddress;
    uint32_t blockPtr;
};

struct Effect_t* new_Delay(struct Delay_t* opaque);

#endif //__DELAY_H__