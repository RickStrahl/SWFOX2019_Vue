import { RuleParamSchema } from '../types';
declare const validate: (value: any, { target, values }: any) => {
    valid: boolean;
    required: any;
};
declare const params: RuleParamSchema[];
export declare const computesRequired = true;
export { validate, params };
declare const _default: {
    validate: (value: any, { target, values }: any) => {
        valid: boolean;
        required: any;
    };
    params: RuleParamSchema[];
    computesRequired: boolean;
};
export default _default;
