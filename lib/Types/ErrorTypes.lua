export type ErrorObjectCreationConfig = {
    Source: 'Server' | 'Client',
}

export type ErrorEvaluator = () -> boolean
export type ErrorObject = {
    className: string,
    new: (ErrorObjectCreationConfig) -> ErrorObject,

    say: (ErrorObject, string) -> ErrorObject,
    setSpeaker: (ErrorObject, string) -> ErrorObject,
    setContext: (ErrorObject, string) -> ErrorObject,
    setTraceback: (ErrorObject, string) -> ErrorObject,
    recommend: (ErrorObject, string) -> ErrorObject,

    implements: (ErrorObject) -> ErrorObject,

    Speakers: {
        InitializationException: string,
        CommandException: string,
        PermissionMismatchException: string,
    },

    Speaker: string?,
    Context: string?,
    Traceback: string?,
    Recommendation: string?,

    Source: string,
    Evaluator: ErrorEvaluator?,
}

return {}