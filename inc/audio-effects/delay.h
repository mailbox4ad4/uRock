#ifndef __DELAY_H__
#define __DELAY_H__

#include "base-effect.h"
#include "delay_img.bmp.h"

struct Delay_t{
    struct Effect_t parent;
    struct parameter_t delayTime;
    struct parameter_t attenuation;
    q31_t cache;
    uint32_t baseAddress;
    uint32_t blockPtr;
};

struct Effect_t* new_Delay();

static struct EffectType_t DelayId __attribute__((unused)) = {
    .name = "Delay",
    .image = delay_img,
    .Init = new_Delay
};


#endif //__DELAY_H__
