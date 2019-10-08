import { ValidationFlags } from '../types';
import { ValidationClassMap } from '../config';
export declare const isNaN: (value: unknown) => boolean;
/**
 * Checks if the values are either null or undefined.
 */
export declare const isNullOrUndefined: (value: unknown) => value is null | undefined;
/**
 * Creates the default flags object.
 */
export declare const createFlags: () => ValidationFlags;
/**
 * Checks if the value is an object.
 */
export declare const isObject: (obj: unknown) => obj is {
    [x: string]: any;
};
export declare function identity<T>(x: T): T;
/**
 * Shallow object comparison.
 */
export declare const isEqual: (lhs: any, rhs: any) => boolean;
export declare const includes: (collection: string | any[], item: any) => boolean;
/**
 * Parses a rule string expression.
 */
export declare const parseRule: (rule: string) => {
    name: string;
    params: string[];
};
/**
 * Debounces a function.
 */
export declare const debounce: (fn: Function, wait?: number, token?: {
    cancelled: boolean;
}) => Function;
/**
 * Emits a warning to the console.
 */
export declare const warn: (message: string) => void;
/**
 * Normalizes the given rules expression.
 */
export declare const normalizeRules: (rules: any) => {
    [x: string]: any[];
};
/**
 * Checks if a function is callable.
 */
export declare const isCallable: (func: unknown) => func is Function;
export declare function computeClassObj(names: ValidationClassMap, flags: ValidationFlags): Record<string, boolean>;
/**
 * Converts an array-like object to array, provides a simple polyfill for Array.from
 */
export declare function toArray<T>(arrayLike: ArrayLike<T>): T[];
export declare function findIndex<T>(arrayLike: ArrayLike<T>, predicate: (item: T) => boolean): number;
/**
 * finds the first element that satisfies the predicate callback, polyfills array.find
 */
export declare function find<T>(arrayLike: ArrayLike<T>, predicate: (item: T) => boolean): T | undefined;
export declare function merge(target: any, source: any): any;
export declare function values<T>(obj: {
    [x: string]: T;
}): T[];
export declare const isEmptyArray: (arr: any[]) => boolean;
export declare const interpolate: (template: string, values: Record<string, any>) => string;
export declare const isSpecified: (val: string | null | undefined) => boolean;
