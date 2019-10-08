import Vue, { VueConstructor } from 'vue';
import { ValidationResult, ValidationFlags, VeeObserver, VNodeWithVeeContext } from '../types';
export declare const ValidationProvider: VueConstructor<{
    messages: string[];
    value: undefined;
    initialized: boolean;
    initialValue: undefined;
    flags: ValidationFlags;
    failedRules: {};
    forceRequired: boolean;
    isDeactivated: boolean;
    id: string;
} & {
    setFlags(flags: Partial<ValidationFlags>): void;
    syncValue(v: any): void;
    reset(): void;
    validate(...args: any[]): Promise<ValidationResult>;
    validateSilent(): Promise<ValidationResult>;
    setErrors(errors: string[]): void;
    applyResult({ errors, failedRules }: Pick<ValidationResult, "errors" | "failedRules">): void;
    registerField(): void;
} & {
    fieldDeps: string[];
    normalizedEvents: string[];
    isRequired: boolean;
    classes: Record<string, boolean>;
    normalizedRules: {
        [x: string]: any[];
    };
} & {
    vid: string;
    name: string;
    mode: TimerHandler;
    rules: any;
    immediate: boolean;
    persist: boolean;
    bails: boolean;
    skipIfEmpty: boolean;
    debounce: number;
    tag: string;
    slim: boolean;
    disabled: boolean;
} & Vue & {
    $_veeObserver: VeeObserver;
    _needsValidation: boolean;
    _inputEventName: string;
    _ignoreImmediate: boolean;
    _pendingValidation?: Promise<ValidationResult> | undefined;
    _resolvedRules: any;
    _veeWatchers: Record<string, Function>;
    $veeDebounce?: number | undefined;
    $veeHandler?: Function | undefined;
    $vnode: VNodeWithVeeContext;
}>;
