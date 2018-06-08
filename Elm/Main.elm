port module DesiredRoute exposing (Model, Msg, main)

import Html exposing (..)
import Html.Attributes exposing (id, class, src, href, alt)


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
    = TitleMode (Maybe Button)
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
update (ChangeButton x) model =
    (TitleMode
        (case x of
            0 ->
                Just ButtonA

            1 ->
                Just ButtonB

            2 ->
                Just ButtonX

            3 ->
                Just ButtonY

            _ ->
                Nothing
        )
    )
        ! [ Cmd.none ]


view : Model -> Html Msg
view model =
    case model of
        TitleMode button->
            let
                buttonText : String
                buttonText =
                    case button of
                        Just ButtonA ->
                            "Aボタン"

                        Just ButtonB ->
                            "Bボタン"

                        Just ButtonX ->
                            "Xボタン"

                        Just ButtonY ->
                            "Yボタン"

                        Nothing ->
                            ""
            in
                div [ id "elm-root" ]
                    [ Html.img [ class "dr-img", src "image/title_logo.jpg" ] []
                    , div [ class "window" ] [ text "せりふ" ]
                    , Html.nav [ class "menu" ] [ text ("メニュー" ++ buttonText) ]
                    ]

        SearchMode ->
            div [] [ text "Search Mode" ]

        BattleMode ->
            div [] [ text "Battle Mode" ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    abxyPressed ChangeButton


init : ( Model, Cmd Msg )
init =
    TitleMode Nothing ! [ elmLoaded "loaded" ]
