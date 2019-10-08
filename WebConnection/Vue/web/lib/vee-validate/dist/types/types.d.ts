import Vue, { VNode } from 'vue';
import { ValidationProvider } from './components/Provider';
export declare type ProviderInstance = InstanceType<typeof ValidationProvider>;
export interface ValidationResult {
    valid: boolean;
    errors: string[];
    failedRules: Record<string, string>;
}
export declare type VueValidationContext = Vue & {
    $_veeObserver?: VeeObserver;
};
export interface ValidationMessageGenerator {
    (field: string, params?: Record<string, any>): string;
}
export declare type ValidationMessageTemplate = string | ValidationMessageGenerator;
export interface ValidationRuleResult {
    data?: Record<string, any>;
    valid: boolean;
    required?: boolean;
}
export declare type ValidationRuleFunction = (value: any, params: any[] | Record<string, any>) => boolean | ValidationRuleResult | Promise<boolean | ValidationRuleResult>;
export interface RuleParamConfig {
    name: string;
    isTarget?: boolean;
    default?: any;
    cast?(value: any): any;
}
export declare type RuleParamSchema = string | RuleParamConfig;
export interface ValidationRuleSchema {
    validate?: ValidationRuleFunction;
    params?: RuleParamSchema[];
    message?: ValidationMessageTemplate;
    lazy?: boolean;
    computesRequired?: boolean;
    castValue?(value: any): any;
}
export declare type ValidationRule = ValidationRuleFunction | ValidationRuleSchema;
export declare type KnownKeys<T> = {
    [K in keyof T]: string extends K ? never : number extends K ? never : K;
} extends {
    [_ in keyof T]: infer U;
} ? U : never;
export interface ValidationFlags {
    untouched: boolean;
    touched: boolean;
    dirty: boolean;
    pristine: boolean;
    valid: boolean;
    invalid: boolean;
    validated: boolean;
    pending: boolean;
    required: boolean;
    changed: boolean;
    [x: string]: boolean | undefined;
}
export interface VeeObserver {
    refs: Record<string, ProviderInstance>;
    subscribe(provider: any, type?: 'provider' | 'observer'): void;
    unsubscribe(provider: any, type?: 'provider' | 'observer'): void;
}
export interface InactiveRefCache {
    errors: string[];
    flags: ValidationFlags;
    failedRules: Record<string, string>;
}
export declare type VNodeWithVeeContext = VNode & {
    context: Vue & {
        $_veeObserver?: VeeObserver;
    };
};
