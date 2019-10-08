import { RuleParamSchema } from '../types';
declare const validate: (value: any, { locale }?: {
    locale?: string | undefined;
}) => boolean;
declare const params: RuleParamSchema[];
export { validate, params };
declare const _default: {
    validate: (value: any, { locale }?: {
        locale?: string | undefined;
    }) => boolean;
    params: RuleParamSchema[];
};
export default _default;
