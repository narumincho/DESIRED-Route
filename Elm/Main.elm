port module DesiredRoute exposing (Model, Msg, main)

import Html exposing (..)
import Html.Attributes exposing (id, class, src, href, alt)
import Svg
import Svg.Attributes as Svga


port elmLoaded : String -> Cmd msg


port abxyPressed : (Int -> msg) -> Sub msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = TitleMode
    | SearchMode
    | BattleMode


type Button
    = ButtonA
    | ButtonB
    | ButtonX
    | ButtonY


type Msg
    = ChangeButton Int


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    model ! [ Cmd.none ]


view : Model -> Html Msg
view model =
    case model of
        TitleMode ->
            div [ id "elm-root" ]
                [ text "Title Mode"
                ]

        SearchMode ->
            div [ id "elm-root" ]
                [ Svg.svg
                    [ Svga.viewBox "0 0 16 9" ]
                    bg
                ]

        BattleMode ->
            div [] [ text "Battle Mode" ]


bg : List (Svg.Svg msg)
bg =
    List.range 0 15
        |> List.concatMap
            (\x ->
                List.range 0 8
                    |> List.map (\y -> ( x, y ))
            )
        |> List.map
            (\( x, y ) ->
                Svg.image
                    [ Svga.xlinkHref "image/bg.png"
                    , Svga.height "1"
                    , Svga.width "1"
                    , Svga.x (toString x)
                    , Svga.y (toString y)
                    ]
                    []
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    abxyPressed ChangeButton


init : ( Model, Cmd Msg )
init =
    SearchMode ! [ elmLoaded "loaded" ]
