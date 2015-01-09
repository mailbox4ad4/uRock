#include "stm32f429i_discovery.h"
#include "stm32f429i_discovery_lcd.h"
#include "stm32f429i_discovery_ts.h"

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

#include "setting.h"
#include "base-effect.h"

DMA_HandleTypeDef hdma_adc2;
ADC_HandleTypeDef hadc2;

extern struct Effect_t *EffectStages[STAGE_NUM];

void UserInterface(void *argument){
    uint8_t values[3];
    //char buf[16];

	TS_StateTypeDef tp;
    uint32_t controllingStage = 0;

    HAL_ADC_Start_DMA(&hadc2, (uint32_t*)values, 3);
    BSP_LCD_Clear(LCD_COLOR_WHITE);
    BSP_LCD_DisplayStringAt(0, 0, (uint8_t*) "uROCK", CENTER_MODE);
    
    vTaskDelay(10);
	while (1) {
		BSP_TS_GetState(&tp);
		if (tp.TouchDetected == 1) {
            controllingStage++;
            if(controllingStage >= 4)
                controllingStage = 0;
		}

        BSP_LCD_Clear(LCD_COLOR_WHITE);

        if(EffectStages[controllingStage] == NULL){
            BSP_LCD_DisplayStringAt(0, 0, (uint8_t*) "uROCK", CENTER_MODE);
        }else{
            BSP_LCD_DisplayStringAt(0, 0, (uint8_t*) "uROCK", CENTER_MODE);
            BSP_LCD_DisplayStringAt(0, 1 * 16, (uint8_t*) EffectStages[controllingStage]->name, CENTER_MODE);

            EffectStages[controllingStage]->adj(EffectStages[controllingStage], values);
        }

       /* 
        ftoa(EffectStages[controllingStage].parameter[0].value, buf, 2);
        BSP_LCD_DisplayStringAt(0, 3 * 16, (uint8_t*) buf, CENTER_MODE);
        ftoa(EffectStages[controllingStage].parameter[1].value, buf, 2);
        BSP_LCD_DisplayStringAt(0, 4 * 16, (uint8_t*) buf, CENTER_MODE);
        ftoa(EffectStages[controllingStage].parameter[2].value, buf, 2);
        BSP_LCD_DisplayStringAt(0, 5 * 16, (uint8_t*) buf, CENTER_MODE);
        */

        vTaskDelay(200);
    }
}