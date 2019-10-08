import Vue, { VueConstructor } from 'vue';
import { ValidationResult, InactiveRefCache, VeeObserver, VNodeWithVeeContext } from '../types';
export declare const ValidationObserver: VueConstructor<{
    refs: Record<string, import("vue/types/vue").CombinedVueInstance<{
        messages: string[];
        value: undefined;
        initialized: boolean;
        initialValue: undefined;
        flags: import("../types").ValidationFlags;
        failedRules: {};
        forceRequired: boolean;
        isDeactivated: boolean;
        id: string;
    } & {
        setFlags(flags: Partial<import("../types").ValidationFlags>): void;
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
    }, object, object, object, Record<never, any>>>;
    refsByName: Record<string, import("vue/types/vue").CombinedVueInstance<{
        messages: string[];
        value: undefined;
        initialized: boolean;
        initialValue: undefined;
        flags: import("../types").ValidationFlags;
        failedRules: {};
        forceRequired: boolean;
        isDeactivated: boolean;
        id: string;
    } & {
        setFlags(flags: Partial<import("../types").ValidationFlags>): void;
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
    }, object, object, object, Record<never, any>>>;
    observers: any[];
    inactiveRefs: Record<string, InactiveRefCache>;
} & {
    subscribe(subscriber: any, kind?: string): void;
    unsubscribe({ vid, name }: any, kind?: string): void;
    validate({ silent }?: {
        silent?: boolean | undefined;
    }): Promise<boolean>;
    reset(): void;
    restoreProviderState(provider: import("vue/types/vue").CombinedVueInstance<{
        messages: string[];
        value: undefined;
        initialized: boolean;
        initialValue: undefined;
        flags: import("../types").ValidationFlags;
        failedRules: {};
        forceRequired: boolean;
        isDeactivated: boolean;
        id: string;
    } & {
        setFlags(flags: Partial<import("../types").ValidationFlags>): void;
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
    }, object, object, object, Record<never, any>>): void;
    removeProvider({ vid, name }: {
        vid: string;
        name: string;
    }): void;
    setErrors(errors: Record<string, string[]>): void;
} & {
    ctx: any;
} & {
    tag: string;
    vid: string;
    slim: boolean;
    disabled: boolean;
} & Vue & {
    $_veeObserver: VeeObserver;
    $vnode: VNodeWithVeeContext;
}>;
