package com.anonyname5.smartlist

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SmartListHomeWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.smartlist_home_widget).apply {
            val launchIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_container, launchIntent)

            setTextViewText(
                R.id.widget_title,
                widgetData.getString("smartlist_title", "SmartList"),
            )
            setTextViewText(
                R.id.widget_today_targets_value,
                widgetData.getString("smartlist_today_targets", "0"),
            )
            setTextViewText(
                R.id.widget_planned_value,
                "Planned: ${widgetData.getString("smartlist_planned", "RM0.00")}",
            )
            setTextViewText(
                R.id.widget_bought_value,
                "Bought: ${widgetData.getString("smartlist_bought", "RM0.00")}",
            )
            setTextViewText(
                R.id.widget_remaining_value,
                "Remaining: ${widgetData.getString("smartlist_remaining", "RM0.00")}",
            )
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
