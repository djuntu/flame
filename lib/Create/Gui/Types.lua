export type LineStyle = 'PlainText' | 'Expressive' | 'Header'
export type Writer = {
    SetContent: (self: Writer, text: string) -> (),
    SetContentColor: (self: Writer, color: Color3) -> (),
    SetHeader: (self: Writer, text: string) -> (),
    Create: (self: Writer, parent: GuiObject) -> Writer,

    Object: Frame & {
        TextBox: TextBox,
        TextLabel: TextLabel,
    }
}
export type Window = {
    Writer: Writer,
    Toggle: (self: Window, toggle: boolean) -> (),
    Focus: (self: Window) -> (),
    GoToFocus: (self: Window) -> (),
    Main: InitializedCLIRegistry,
}
export type Autocomplete = {}
export type InitializedCLIRegistry = {
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
    ExecuteAction: (self: CLIRegistry, ...string) -> ()
}
export type CLI = ScreenGui & {
    Window: ScrollingFrame
}

return {}