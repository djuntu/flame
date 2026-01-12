export type LineStyle = 'PlainText' | 'Expressive' | 'Header'
export type Writer = {
    SetContent: (self: Writer, text: string) -> Writer,
    SetContentColor: (self: Writer, color: Color3) -> Writer,
    SetHeader: (self: Writer, text: string) -> Writer,
    Create: (self: Writer, parent: GuiObject) -> Writer,

    Object: Frame & {
        TextBox: TextBox,
        TextLabel: TextLabel,
    }
}

export type Line = {
    SetContent: (self: Writer, text: string) -> Line,
    SetContentColor: (self: Writer, color: Color3) -> Line,
    SetHeader: (self: Writer, text: string) -> Line,
    SetExpression: (self: Writer, expressionid: string) -> Line,
    Create: (self: Writer, parent: GuiObject) -> Line,

    Object: Frame
}
export type Window = {
    Writer: Writer,
    Toggle: (self: Window, toggle: boolean) -> (),
    Focus: (self: Window) -> (),
    GoToFocus: (self: Window) -> (),
    FocusLost: (self: Window, enterPressed: boolean) -> boolean,
    WriteLine: (self: Window, text: string, lineStyle: LineStyle?, color: Color3, header: string?, expression: string?) -> nil,
    SetProcessableEntry: (self: Window, bool: boolean, canProcessResponse: string?) -> nil,
    ClearWindowInput: (self: Window) -> nil,
    Main: InitializedCLIRegistry,
}
export type ContextCommuniction = string | {
    Message: string,
    LineStyle: 'PlainText' | 'Expressive' | 'Header',
    ImageId: string?,
    HeaderText: string?,
    Color: Color3?,
}
export type Autocomplete = {
    Main: CLIRegistry,
    Object: ScrollingFrame & {
        Title: TextLabel,
        Description: TextLabel,
    },
    RawOptions: {string},
    CurrentSelectionMount: number,

    CycleInput: (self: Autocomplete, up: string, userInput: string) -> nil,
    SelectFromTextButon: (self: Autocomplete, textButton: TextButton, userInput: string) -> nil,
    Visible: (self: Autocomplete, bool: boolean) -> nil,
    GetSelected: (self: Autocomplete) -> TextButton?,
    Select: (self: Autocomplete, n: number, userInput: string) -> nil,
    SetSelectedInput: (self: Autocomplete, userInput: string) -> nil,
    SetContext: (self: Autocomplete, name: string, type: string, description: string?) -> nil,
    SetPosition: (self: Autocomplete, udim2: UDim2) -> nil,
    DisplayOptions: (self: Autocomplete, options: string) -> nil,
    AdjustMaxExtents: (self: Autocomplete, memberCount: number) -> nil,
    CreateOption: (self: Autocomplete, text: string) -> TextButton,
    Autocomplete: (self: Autocomplete, targetInput: string?) -> nil,
    Create: (self: Autocomplete, parent: ScreenGui) -> ScrollingFrame,
}
export type InitializedCLIRegistry = {
    UserInput: string,
    Gui: CLI,
    Window: Window,
    Autocomplete: Autocomplete
}
export type Events = {
    Main: InitializedCLIRegistry
}
export type CLIRegistry = {
    Handler: InitializedCLIRegistry,
    Events: Events,
    Navigation: {[Enum.KeyCode]: boolean},
    Communicate: (self: CLIRegistry, communication: ContextCommuniction) -> (),
    InvokeEvent: (self: CLIRegistry, eventName: string) -> (),
}
export type CLI = ScreenGui & {
    Window: ScrollingFrame
}

return {}