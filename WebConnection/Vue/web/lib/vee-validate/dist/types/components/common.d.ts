import { VNodeDirective, VNode } from 'vue';
import { ValidationResult, ValidationFlags, KnownKeys, ProviderInstance } from '../types';
export interface ValidationContext extends Pick<ValidationFlags, KnownKeys<ValidationFlags>> {
    errors: string[];
    classes: Record<string, boolean>;
    valid: boolean;
    failedRules: Record<string, string>;
    reset: () => void;
    validate: (evtOrNewValue: Event | any) => Promise<ValidationResult>;
    ariaInput: {
        'aria-invalid': 'true' | 'false';
        'aria-required': 'true' | 'false';
        'aria-errormessage': string;
    };
    ariaMsg: {
        id: string;
        'aria-live': 'off' | 'assertive';
    };
}
export declare function createValidationCtx(ctx: ProviderInstance): ValidationContext;
export declare function onRenderUpdate(vm: ProviderInstance, model: VNodeDirective | undefined): void;
export declare function computeModeSetting(ctx: ProviderInstance): import("../modes").InteractionSetting;
export declare function createCommonHandlers(vm: ProviderInstance): {
    onInput: (e: any) => void;
    onBlur: () => void;
    onValidate: Function;
};
export declare function addListeners(vm: ProviderInstance, node: VNode): void;
