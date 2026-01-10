local UserInputService = game:GetService("UserInputService")
local BuildTypes = require(script.Parent.BuildTypes)
local ErrorTypes = require(script.Parent.ErrorTypes)

export type Dictionary<T> = {[T]: boolean}
export type KeyList<K, V> = {[K]: V}
export type List<T> = {T}

export type Registry = {
    ObjectProps: Dictionary<string>,
    CommandArguments: Dictionary<string>,
    MiddlewareArguments: Dictionary<string>,
    Middleware: {
        BeforeExecution: Middleware?,
        AfterExecution: Middleware?,
    },
    Flame: _Flame,
    Commands: KeyList<string, Command>,
    Backlog: List<Command>,
    UnknownError: ErrorTypes.ErrorObject,

    Register: (self: Registry, command: Command) -> nil,
    RegisterCommand: (self: Registry, command: Command) -> nil,
    VerifyCommandProps: (self: Registry, props: CommandProps) -> boolean,
    VerifyCommandMiddleware: (self: Registry, middleware: Middleware?) -> boolean,
    VerifyObject: (self: Registry, object: any?) -> boolean,
    CheckPresence: (self: Registry, commandName: string) -> boolean,
    EvaluateBacklog: (self: Registry) -> Command?,
    EvaluateAndFlushBacklog: (self: Registry) -> nil,
    MarkCommandExecutionBuffer: (self: Registry, executionMarker: ExecutionState) -> nil,
    Get: (self: Registry, target: string, scope: string) -> (Command | Middleware)?,
    GetCommand: (self: Registry, commandName: string) -> Command?,
    GetSubcommands: (self: Registry, command: Command) -> List<Subcommand>,
    GetMdwr: (self: Registry, command: Command, middleware: MdwrType) -> Middleware?,

    isKind: (object: Command | any) -> boolean,
    extract: (key: string) -> (Command, List<Subcommand>),
}
export type Middleware = (CommandContext) -> boolean?
export type MiddlewareAbsorber = {
    new: (self: MiddlewareAbsorber, mdwrType: MdwrType, callback: Middleware) -> MiddlewareReference
}
export type MiddlewareReference = {
    [string]: Middleware
}
export type ExecutionState = {}
export type MdwrType = 'BeforeExecution' | 'AfterExecution'
export type Scope = 'Command' | 'Hook'

export type State = {}
export type DispatchContext = {
    Executor: Player?,
    IsRobot: boolean,
    RawText: string,
    RawArgs: string,
    Arguments: KeyList<string, ArgumentContext>,
    GetArgument: (self: DispatchContext, arg: string) -> string,
}
export type ExecutionContext = {
    Name: string,
    Group: string,
    Aliases: {string}?,

    GetStore: (self: ExecutionContext) -> CommandStore,
    GetState: (self: ExecutionContext) -> State,
}
export type CommandContext = DispatchContext & ExecutionContext
export type CommandStore = {[string]: Executable}
export type Realm = 'Server' | 'Client' | 'Shared'
export type CommandStyle = 'Primary' | 'Secondary'
export type CommandEvaluator = (CommandContext) -> any?
export type CommandOptions = {
    Hoist: CommandProps,
    Realm: Realm,
    Arguments: (GivenArguments | {})?,
    Name: string?
}
export type CommandBuilder = (options: CommandOptions) -> (Executor: (context: CommandContext) -> ()) -> ()
export type UserCommandBuilder = {
    Primary: CommandBuilder,
    Secondary: CommandBuilder,
}
export type Executable = {
    Executor: CommandEvaluator,
    Realm: Realm,
    ArgumentStruct: ArgumentStruct,
}
export type Command = {
    Name: string,
    Aliases: {string}?,
    Group: string?,
    Middleware: {
        BeforeExecution: Middleware?,
        AfterExecution: Middleware?
    }?,
    State: State,
    Store: CommandStore,

    extract: (self: Command, subcommand: string) -> Executable?
}
export type Subcommand = {
    Realm: Realm,
    Exec: CommandEvaluator,
    ArgumentStruct: ArgumentStruct,
}
export type CommandProps = {
    Name: string,
    Aliases: ({string} | {})?,
    Group: string?,
    Middleware: {
        BeforeExecution: Middleware?,
        AfterExecution: Middleware?
    }?,
    Subcommands: { [string]: Subcommand },

    New: ((any...) -> State)?
}

export type Util = {}
export type CommandExecutionResponse = string?
export type Dispatcher = {
    Flame: _Flame,

    Evaluate: (self: Dispatcher, executor: Player?, command: Command, executable: Executable, rawArgs: string, rawText: string) -> (boolean, CommandContext),
    Provide: (self: Dispatcher, executor: Player?, command: Command, rawArgs: string, rawText: string) -> CommandContext,
    EvaluateAndRun: (self: Dispatcher, executor: Player?, rawText: string) -> CommandExecutionResponse,
    Dispatch: (self: Dispatcher, rawText: string) -> CommandExecutionResponse,
    Execute: (self: Dispatcher, command: Command, commandEntryPoint: CommandStyle | string, commandContext: CommandContext) -> CommandExecutionResponse,
    EvaluateAndRunAsParsed: (self: Dispatcher, commandName: string, commandEntryPoint: CommandStyle | string, rawArgs: string, rawText: string) -> CommandExecutionResponse,
}

export type _Flame = {
    _Dispatcher: (_Flame) -> Dispatcher,
    _Registry: (_Flame) -> Registry,

    Dispatcher: Dispatcher,
    Registry: Registry,

    Middleware: {
        BeforeExecution: Middleware?,
        AfterExecution: Middleware?,
    }
}

export type Hint = List<string>
export type Arguments = {
    Types: TypeRegistry,

    StructHasArgument: (struct: ArgumentStruct, name: string) -> number | boolean?,
    Struct: (givenArguments: GivenArguments) -> ArgumentContext,
    Evaluator: (stringType: string, argumentInput: string?) -> (boolean, Hint),
    Seems: (struct: ArgumentStruct, argumentName: string, userInput: string?) -> boolean,
    Dilute: (struct: ArgumentStruct, userInput: string?) -> (boolean, KeyList<string, ArgumentContext>),
    Context: (name: string, userInput: string?) -> ArgumentContext,
    Register: () -> (),
    Inherit: (name: string) -> ArgumentType,
    Make: (argumentName: string, argumentEvaluator: DataType | EnumType) -> (() -> (string, DataType | EnumType)),
    MakeEnumType: (name: string, list: List<string>) -> EnumType,
    MakeDataType: (entry: DataType?) -> DataType,
    typeOf: (t: DataType | EnumType) -> string
}
export type DataType = {
    Transform: (value: any?) -> any?,
    Validate: (value: string) -> boolean|string,
    Parse: (value: string) -> any?,
    Search: ((value: string) -> List<string>)?,
}
export type ArgumentStruct = {
    [number]: {
        Name: string,
        Evaluate: (input: string) -> (boolean, List<string>),
        Transform: (value: any?) -> any?,
        Parse: (value: string) -> any?,
        Search: ((value: string) -> List<string>)?,
    }
}
export type GivenArguments = List<CommandArgument>
export type ArgumentContext = {
    Name: string,
    Input: string,
}
export type CommandArgument = {
    Type: string,
    Name: string,
    Description: string?,
    Optional: boolean?
}
export type EnumType = KeyList<string, boolean>
export type ArgumentType = () -> (string, DataType | ArgumentType)
export type TypeRegistry = {[string]: ArgumentType}

export type _View = {
    addCommand: (self: _Flame, module: ModuleScript) -> _Flame,
    addMiddleware: (self: _Flame, module: ModuleScript) -> _Flame,
    addType: (self: _Flame, module: ModuleScript) -> _Flame,
}

export type FlameMain<Context> = BuildTypes.Builder<Context> & _Flame & _View

return {}